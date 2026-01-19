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
    var savedProfiles: [SavedProfile] = []
    var isInitialLoading = false
    var isRefreshing = false
    var errorMessage: String?

    private var lastTokenHash: String?

    private func hashToken(_ token: String) -> String {
        let data = Data(token.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    init() {
        loadSavedProfiles()
    }

    func loadSavedProfiles() {
        savedProfiles = ProfileStorage.loadProfiles()
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

    func saveCurrentProfile(name: String) {
        guard let usageData = currentUsageData else { return }
        guard let creds = try? KeychainService.getCredentials() else { return }

        let profile = SavedProfile(
            name: name,
            usageData: usageData,
            accessToken: creds.claudeAiOauth.accessToken,
            refreshToken: creds.claudeAiOauth.refreshToken,
            expiresAt: creds.claudeAiOauth.expiresAt
        )
        ProfileStorage.addProfile(profile)
        loadSavedProfiles()
    }

    func deleteProfile(id: UUID) {
        ProfileStorage.deleteProfile(id: id)
        loadSavedProfiles()
    }

    func renameProfile(id: UUID, newName: String) {
        ProfileStorage.renameProfile(id: id, newName: newName)
        loadSavedProfiles()
    }

    func refreshSavedProfile(id: UUID) async {
        guard let profile = savedProfiles.first(where: { $0.id == id }) else { return }

        do {
            let newUsageData = try await APIService.fetchUsageData(withToken: profile.accessToken)
            ProfileStorage.updateProfileUsageData(id: id, usageData: newUsageData)
            loadSavedProfiles()
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
}
