//
//  KeychainService.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import Foundation
import Security

class KeychainService {
    static func getAccessToken() throws -> String {
        let credentials = try getCredentials()
        return credentials.claudeAiOauth.accessToken
    }

    static func getCredentials() throws -> Credentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }

        guard let data = item as? Data else {
            throw KeychainError.invalidData
        }

        return try JSONDecoder().decode(Credentials.self, from: data)
    }

    enum KeychainError: Error {
        case itemNotFound
        case invalidData
        case decodingError
    }
}
