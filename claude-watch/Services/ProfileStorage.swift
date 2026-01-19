//
//  ProfileStorage.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import Foundation
import Security

struct ProfileStorage {
    private static let keychainService = "claude-watch-profiles"

    static func loadProfiles() -> [SavedProfile] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return []
        }

        do {
            let store = try JSONDecoder().decode(SavedProfilesStore.self, from: data)
            return store.profiles
        } catch {
            print("Failed to decode profiles: \(error)")
            return []
        }
    }

    static func saveProfiles(_ profiles: [SavedProfile]) {
        let store = SavedProfilesStore(profiles: profiles)

        do {
            let data = try JSONEncoder().encode(store)

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService
            ]

            let existingStatus = SecItemCopyMatching(query as CFDictionary, nil)

            if existingStatus == errSecSuccess {
                let updateQuery: [String: Any] = [
                    kSecValueData as String: data
                ]
                SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
            } else {
                var addQuery = query
                addQuery[kSecValueData as String] = data
                SecItemAdd(addQuery as CFDictionary, nil)
            }
        } catch {
            print("Failed to encode profiles: \(error)")
        }
    }

    static func addProfile(_ profile: SavedProfile) {
        var profiles = loadProfiles()
        profiles.insert(profile, at: 0)
        saveProfiles(profiles)
    }

    static func deleteProfile(id: UUID) {
        var profiles = loadProfiles()
        profiles.removeAll { $0.id == id }
        saveProfiles(profiles)
    }

    static func renameProfile(id: UUID, newName: String) {
        var profiles = loadProfiles()
        if let index = profiles.firstIndex(where: { $0.id == id }) {
            profiles[index].name = newName
            saveProfiles(profiles)
        }
    }

    static func updateProfileUsageData(id: UUID, usageData: UsageData) {
        var profiles = loadProfiles()
        if let index = profiles.firstIndex(where: { $0.id == id }) {
            profiles[index].usageData = usageData
            saveProfiles(profiles)
        }
    }
}
