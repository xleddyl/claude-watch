//
//  ProfileRowView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct ProfileRowView: View {
    let profile: SavedProfile
    let isExpanded: Bool
    var onRefresh: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))

            Text(profile.name)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()

            if let fiveHour = profile.usageData.fiveHour {
                Text("\(Int(fiveHour.utilization))%")
                    .font(.subheadline)
                    .foregroundColor(utilizationColor(fiveHour.utilization))

                Text(formatResetTime(fiveHour.resetsAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let onRefresh = onRefresh {
                Button {
                    onRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func utilizationColor(_ utilization: Double) -> Color {
        if utilization > 90 {
            return .red
        } else if utilization > 70 {
            return .orange
        } else {
            return .green
        }
    }

    private func formatResetTime(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: isoString) else {
            isoFormatter.formatOptions = [.withInternetDateTime]
            guard let date = isoFormatter.date(from: isoString) else {
                return isoString
            }
            return formatDate(date)
        }
        return formatDate(date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}
