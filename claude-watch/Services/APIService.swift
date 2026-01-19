//
//  APIService.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import Foundation

class APIService {
    static func fetchUsageData() async throws -> UsageData {
        let token = try KeychainService.getAccessToken()
        return try await fetchUsageData(withToken: token)
    }

    static func fetchUsageData(withToken token: String) async throws -> UsageData {
        guard let url = URL(string: "https://api.anthropic.com/oauth/usage") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("claude-code/2.1.11", forHTTPHeaderField: "user-agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError
        }

        let usageData = try JSONDecoder().decode(UsageData.self, from: data)
        return usageData
    }

    enum APIError: Error {
        case invalidURL
        case httpError
        case decodingError
    }
}
