//
//  ProfileManager.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import CryptoKit
import Foundation

@Observable
class ProfileManager {
    var currentUsageData: UsageData?
    var isInitialLoading = false
    var isRefreshing = false
    var errorMessage: String?
    var lastUpdated: Date?
    var subscriptionType: String?

    private var lastTokenHash: String?

    private func hashToken(_ token: String) -> String {
        let data = Data(token.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func fetchCurrentUsage() async {
        // Check if token has changed (account switch) using hash comparison
        if let currentToken = try? KeychainService.getAccessToken() {
            let currentHash = hashToken(currentToken)
            if currentHash != lastTokenHash {
                // Token changed - invalidate cached data
                currentUsageData = nil
                lastTokenHash = currentHash
            }
        }

        // Load subscription type from credentials
        if let creds = try? KeychainService.getCredentials() {
            subscriptionType = creds.claudeAiOauth.subscriptionType
        }

        let isFirstLoad = currentUsageData == nil

        if isFirstLoad {
            isInitialLoading = true
        } else {
            isRefreshing = true
        }
        errorMessage = nil

        do {
            let usageData = try await APIService.fetchUsageData()
            currentUsageData = usageData
            lastUpdated = Date()
            // Update hash after successful fetch
            if let token = try? KeychainService.getAccessToken() {
                lastTokenHash = hashToken(token)
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }

        isInitialLoading = false
        isRefreshing = false
    }
}
