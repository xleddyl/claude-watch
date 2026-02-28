# claude-watch

Claude Code statusline showing model, git branch, API usage (5h/7d), and context window.

## Installation

**1. Copy the scripts**

```sh
cp fetch-usage.sh ~/.claude/fetch-usage.sh
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/fetch-usage.sh ~/.claude/statusline-command.sh
```

**2. Merge `settings.json` into `~/.claude/settings.json`**

Add the `statusLine` and `hooks` blocks from `settings.json` into your existing `~/.claude/settings.json`. If you don't have one yet, copy it directly:

```sh
cp settings.json ~/.claude/settings.json
```

**3. Trigger an initial fetch (optional)**

```sh
bash ~/.claude/fetch-usage.sh
```

The usage cache will otherwise populate automatically on the next tool call or Claude response.

## How it works

- **`statusline-command.sh`** — reads the JSON piped by Claude Code and renders two lines: model/folder/branch, then usage stats and context window.
- **`fetch-usage.sh`** — reads the OAuth token from `~/.claude/.credentials.json`, caches it in `/tmp/.claude_token_cache` for 15 minutes, hits the `/oauth/usage` endpoint (3s timeout), and writes results to `/tmp/.claude_usage_cache`. On failure the stale cache is preserved.
- **`settings.json`** — wires up the statusline command and triggers `fetch-usage.sh` in the background on `PreToolUse` and `Stop` hooks.

## Dependencies

- `jq`
- `curl`
- `git` (optional, for branch display)
