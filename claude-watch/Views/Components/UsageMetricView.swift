//
//  UsageMetricView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct UsageMetricView: View {
    let title: String
    let icon: String
    let utilization: Double
    let resetsAt: String?

    private let accentIcon = Color(red: 0.77, green: 0.49, blue: 0.37) // #C47C5E

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentIcon)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("\(Int(utilization))%")
                    .font(.system(size: 16, weight: .bold))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.23, green: 0.23, blue: 0.23)) // #3A3A3A
                        .frame(height: 6)

                    Capsule()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * min(utilization, 100) / 100, height: 6)
                }
            }
            .frame(height: 6)

            if let resetsAt = resetsAt {
                Text("Resets \(formatResetTime(resetsAt))")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58)) // #8E8E93
            }
        }
    }

    private var progressColor: Color {
        if utilization > 90 {
            return Color(red: 0.9, green: 0.35, blue: 0.35) // Red
        } else if utilization > 70 {
            return Color(red: 0.85, green: 0.65, blue: 0.34) // #D9A556 Mustard Yellow
        } else {
            return Color(red: 0.42, green: 0.62, blue: 0.48) // #6B9E7B Muted Green
        }
    }

    private func formatResetTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date?
        date = formatter.date(from: isoString)

        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }

        guard let resetDate = date else {
            return isoString
        }

        return formatRelativeTime(resetDate)
    }

    private func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let interval = date.timeIntervalSince(now)

        if interval <= 0 {
            return "now"
        }

        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 24 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE h:mm a"
            return dayFormatter.string(from: date)
        } else if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes)m"
        }
    }
}
