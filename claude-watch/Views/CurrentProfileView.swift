//
//  CurrentProfileView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct CurrentProfileView: View {
    @Environment(ProfileManager.self) private var profileManager

    private let badgeBackground = Color(red: 0.25, green: 0.19, blue: 0.16) // #3F3028
    private let badgeText = Color(red: 1.0, green: 0.62, blue: 0.41) // #FF9F68
    private let secondaryText = Color(red: 0.6, green: 0.6, blue: 0.62) // #98989D
    private let dividerColor = Color(red: 0.25, green: 0.25, blue: 0.25)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Claude Usage")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                if let subscriptionType = profileManager.subscriptionType {
                    Text(subscriptionType.capitalized)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(badgeBackground)
                        )
                }
            }
            .padding(.bottom, 16)

            // Content
            if profileManager.isInitialLoading {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if let usageData = profileManager.currentUsageData {
                VStack(alignment: .leading, spacing: 14) {
                    // 5-Hour Window
                    UsageMetricView(
                        title: "5-Hour Window",
                        icon: "clock",
                        utilization: usageData.fiveHour?.utilization ?? 0,
                        resetsAt: usageData.fiveHour?.resetsAt
                    )

                    dividerColor.frame(height: 1)

                    // Weekly
                    UsageMetricView(
                        title: "Weekly",
                        icon: "calendar",
                        utilization: usageData.sevenDay?.utilization ?? 0,
                        resetsAt: usageData.sevenDay?.resetsAt
                    )

                    dividerColor.frame(height: 1)

                    // Extra Usage
                    ExtraUsageView(extraUsage: usageData.extraUsage)
                }
            }

            if let errorMessage = profileManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
            }

            Spacer(minLength: 16)

            dividerColor.frame(height: 1)

            // Footer - Updated time + Refresh
            HStack {
                Text(lastUpdatedText)
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44)) // #6F6F6F

                Button {
                    Task {
                        await profileManager.fetchCurrentUsage()
                    }
                } label: {
                    Image(systemName: profileManager.isRefreshing ? "arrow.trianglehead.2.clockwise" : "arrow.clockwise")
                        .font(.system(size: 10))
                        .foregroundColor(secondaryText)
                }
                .buttonStyle(.plain)
                .disabled(profileManager.isInitialLoading || profileManager.isRefreshing)

                Spacer()
            }
            .padding(.top, 10)

                    }
        .onAppear {
            Task {
                await profileManager.fetchCurrentUsage()
            }
        }
    }

    private var lastUpdatedText: String {
        guard let lastUpdated = profileManager.lastUpdated else {
            return "Not updated yet"
        }

        let interval = Date().timeIntervalSince(lastUpdated)
        let seconds = Int(interval)

        if seconds < 60 {
            return "Updated \(seconds) sec ago"
        } else {
            let minutes = seconds / 60
            return "Updated \(minutes) min ago"
        }
    }
}
