//
//  SavedProfile.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import Foundation

struct SavedProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    let savedAt: Date
    var usageData: UsageData
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int64

    init(id: UUID = UUID(), name: String, savedAt: Date = Date(), usageData: UsageData, accessToken: String, refreshToken: String, expiresAt: Int64) {
        self.id = id
        self.name = name
        self.savedAt = savedAt
        self.usageData = usageData
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

struct SavedProfilesStore: Codable {
    var profiles: [SavedProfile]
}
