//
//  ProfileDetailView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct ProfileDetailView: View {
    let usageData: UsageData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            UsageMetricView(
                title: "5 Hour Limit",
                utilization: usageData.fiveHour?.utilization ?? 0,
                resetsAt: usageData.fiveHour?.resetsAt
            )

            UsageMetricView(
                title: "7 Day Limit",
                utilization: usageData.sevenDay?.utilization ?? 0,
                resetsAt: usageData.sevenDay?.resetsAt
            )

            ExtraUsageView(extraUsage: usageData.extraUsage)
        }
    }
}
