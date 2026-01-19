//
//  Credentials.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import Foundation

struct Credentials: Codable {
    let claudeAiOauth: ClaudeAiOauth
}

struct ClaudeAiOauth: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int64
    let scopes: [String]
    let subscriptionType: String
    let rateLimitTier: String
}
