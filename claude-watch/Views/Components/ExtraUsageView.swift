//
//  ExtraUsageView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct ExtraUsageView: View {
    let extraUsage: ExtraUsage?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let extra = extraUsage, extra.isEnabled,
               let usedCredits = extra.usedCredits,
               let monthlyLimit = extra.monthlyLimit,
               let utilization = extra.utilization {
                HStack {
                    Text("Extra Usage")
                        .font(.subheadline)
                    Spacer()
                    Text("\(usedCredits)/\(monthlyLimit)")
                        .font(.subheadline)
                }

                ProgressView(value: utilization / 100)
                    .tint(utilizationColor(utilization))

                Text("\(Int(utilization))% used")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    Text("Extra Usage")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Non abilitato")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                ProgressView(value: 0)
                    .tint(.gray)
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
}
