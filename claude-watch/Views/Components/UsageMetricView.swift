//
//  UsageMetricView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct UsageMetricView: View {
    let title: String
    let utilization: Double
    let resetsAt: String?

    init(title: String, utilization: Double, resetsAt: String? = nil) {
        self.title = title
        self.utilization = utilization
        self.resetsAt = resetsAt
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(utilization))%")
                    .font(.subheadline)
                    .foregroundColor(utilizationColor)
            }

            ProgressView(value: utilization / 100)
                .tint(utilizationColor)

            if let resetsAt = resetsAt {
                Text("Resets: \(formatResetTime(resetsAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var utilizationColor: Color {
        if utilization > 90 {
            return .red
        } else if utilization > 70 {
            return .orange
        } else {
            return .green
        }
    }

    private func formatResetTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            return isoString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .short
        outputFormatter.timeStyle = .short

        return outputFormatter.string(from: date)
    }
}
