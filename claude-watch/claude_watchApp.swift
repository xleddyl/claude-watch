//
//  claude_watchApp.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

@main
struct claude_watchApp: App {
    @State private var profileManager = ProfileManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(profileManager)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 11))
                if let usage = profileManager.currentUsageData?.fiveHour {
                    Text("\(Int(usage.utilization))%")
                        .font(.system(size: 11, weight: .medium))
                }
            }
            .task {
                await profileManager.fetchCurrentUsage()
            }
        }
        .menuBarExtraStyle(.window)
    }
}
