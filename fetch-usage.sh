#!/bin/sh
# Fetches Claude API usage stats and writes them to /tmp/.claude_usage_cache.
# Line 1: five_hour.utilization (integer %)
# Line 2: seven_day.utilization (integer %)
# Line 3: five_hour.resets_at (raw ISO string)
# Line 4: seven_day.resets_at (raw ISO string)

CACHE_FILE="/tmp/.claude_usage_cache"
TOKEN_CACHE="/tmp/.claude_token_cache"
TOKEN_TTL=900

CLIENT_ID="9d1c250a-e61b-44d9-88ed-5944d1962f5e"
OAUTH_ENDPOINT="https://api.anthropic.com/v1/oauth/token"
USAGE_ENDPOINT="https://api.anthropic.com/oauth/usage"

get_creds_json() {
  _raw=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  [ -z "$_raw" ] && return 1
  _decoded=$(printf '%s' "$_raw" | xxd -r -p 2>/dev/null)
  if printf '%s' "$_decoded" | jq empty 2>/dev/null; then
    printf '%s' "$_decoded"
  else
    printf '%s' "$_raw"
  fi
}

refresh_access_token() {
  _creds=$1
  _refresh=$(printf '%s' "$_creds" | jq -r '.claudeAiOauth.refreshToken // empty' 2>/dev/null)
  [ -z "$_refresh" ] && return 1

  _resp=$(curl -s -m 5 \
    -X POST "$OAUTH_ENDPOINT" \
    -H "Content-Type: application/json" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -d "{\"grant_type\":\"refresh_token\",\"refresh_token\":\"$_refresh\",\"client_id\":\"$CLIENT_ID\"}" 2>/dev/null)

  _new_access=$(printf '%s' "$_resp" | jq -r '.access_token // empty' 2>/dev/null)
  _new_refresh=$(printf '%s' "$_resp" | jq -r '.refresh_token // empty' 2>/dev/null)
  _expires_in=$(printf '%s' "$_resp" | jq -r '.expires_in // empty' 2>/dev/null)
  [ -z "$_new_access" ] && return 1

  _expires_at=$(( $(date -u +%s) * 1000 + _expires_in * 1000 ))

  _updated=$(printf '%s' "$_creds" | jq \
    --arg at "$_new_access" \
    --arg rt "${_new_refresh:-$_refresh}" \
    --argjson ea "$_expires_at" \
    '.claudeAiOauth.accessToken = $at | .claudeAiOauth.refreshToken = $rt | .claudeAiOauth.expiresAt = $ea' 2>/dev/null)

  if [ -n "$_updated" ]; then
    _hex=$(printf '%s' "$_updated" | xxd -p | tr -d '\n')
    security delete-generic-password -s "Claude Code-credentials" >/dev/null 2>&1
    security add-generic-password -s "Claude Code-credentials" -a "" -w "$_hex" 2>/dev/null
  fi

  printf '%s' "$_new_access"
}

# --- get token (with cache) ---
token=""
if [ -f "$TOKEN_CACHE" ]; then
  cache_age=$(( $(date -u +%s) - $(stat -f %m "$TOKEN_CACHE" 2>/dev/null || echo 0) ))
  if [ "$cache_age" -lt "$TOKEN_TTL" ]; then
    token=$(cat "$TOKEN_CACHE" 2>/dev/null)
  fi
fi

if [ -z "$token" ]; then
  creds_json=$(get_creds_json)
  [ -z "$creds_json" ] && exit 0

  expires_at=$(printf '%s' "$creds_json" | jq -r '.claudeAiOauth.expiresAt // 0' 2>/dev/null)
  now_ms=$(( $(date -u +%s) * 1000 ))

  if [ "$now_ms" -ge "$expires_at" ]; then
    token=$(refresh_access_token "$creds_json")
    [ -z "$token" ] && exit 0
  else
    token=$(printf '%s' "$creds_json" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    [ -z "$token" ] && exit 0
  fi
  printf '%s' "$token" > "$TOKEN_CACHE"
fi

# --- fetch usage ---
usage_json=$(curl -s -m 3 \
  -H "accept: application/json" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "authorization: Bearer $token" \
  -H "user-agent: claude-code/2.1.11" \
  "$USAGE_ENDPOINT" 2>/dev/null)

# If 401, token might have expired mid-cache; try refresh once
if printf '%s' "$usage_json" | grep -q '"authentication_error"' 2>/dev/null; then
  rm -f "$TOKEN_CACHE"
  creds_json=$(get_creds_json)
  [ -z "$creds_json" ] && exit 0
  token=$(refresh_access_token "$creds_json")
  [ -z "$token" ] && exit 0
  printf '%s' "$token" > "$TOKEN_CACHE"

  usage_json=$(curl -s -m 3 \
    -H "accept: application/json" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "authorization: Bearer $token" \
    -H "user-agent: claude-code/2.1.11" \
    "$USAGE_ENDPOINT" 2>/dev/null)
fi

[ -z "$usage_json" ] && exit 0

five_h_raw=$(printf '%s' "$usage_json" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
seven_d_raw=$(printf '%s' "$usage_json" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
five_h_reset=$(printf '%s' "$usage_json" | jq -r '.five_hour.resets_at // ""' 2>/dev/null)
seven_d_reset=$(printf '%s' "$usage_json" | jq -r '.seven_day.resets_at // ""' 2>/dev/null)

if [ -n "$five_h_raw" ] && [ -n "$seven_d_raw" ]; then
  five_h=$(printf "%.0f" "$five_h_raw")
  seven_d=$(printf "%.0f" "$seven_d_raw")
  printf '%s\n%s\n%s\n%s\n' "$five_h" "$seven_d" "$five_h_reset" "$seven_d_reset" > "$CACHE_FILE"
fi
