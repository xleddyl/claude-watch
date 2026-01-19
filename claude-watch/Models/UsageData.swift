//
//  UsageData.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import Foundation

struct UsageData: Codable, Identifiable {
    let id: UUID

    init(fiveHour: UsageMetric?, sevenDay: UsageMetric?, extraUsage: ExtraUsage?) {
        self.id = UUID()
        self.fiveHour = fiveHour
        self.sevenDay = sevenDay
        self.extraUsage = extraUsage
    }

    let fiveHour: UsageMetric?
    let sevenDay: UsageMetric?
    let extraUsage: ExtraUsage?

    enum CodingKeys: String, CodingKey {
        case id
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case extraUsage = "extra_usage"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.fiveHour = try container.decodeIfPresent(UsageMetric.self, forKey: .fiveHour)
        self.sevenDay = try container.decodeIfPresent(UsageMetric.self, forKey: .sevenDay)
        self.extraUsage = try container.decodeIfPresent(ExtraUsage.self, forKey: .extraUsage)
    }
}

struct UsageMetric: Codable {
    let utilization: Double
    let resetsAt: String

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

struct ExtraUsage: Codable {
    let isEnabled: Bool
    let monthlyLimit: Int?
    let usedCredits: Int?
    let utilization: Double?

    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case monthlyLimit = "monthly_limit"
        case usedCredits = "used_credits"
        case utilization
    }
}

extension UsageData {
    static var placeholder: UsageData {
        UsageData(
            fiveHour: UsageMetric(utilization: 0, resetsAt: "—"),
            sevenDay: UsageMetric(utilization: 0, resetsAt: "—"),
            extraUsage: nil
        )
    }
}
