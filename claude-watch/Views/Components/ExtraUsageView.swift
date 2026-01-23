//
//  ExtraUsageView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct ExtraUsageView: View {
    let extraUsage: ExtraUsage?

    private let accentIcon = Color(red: 0.77, green: 0.49, blue: 0.37) // #C47C5E
    private let secondaryText = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93
    private let trackColor = Color(red: 0.23, green: 0.23, blue: 0.23) // #3A3A3A

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let extra = extraUsage, extra.isEnabled,
               let usedCredits = extra.usedCredits,
               let monthlyLimit = extra.monthlyLimit,
               let utilization = extra.utilization {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(accentIcon)
                    Text("Extra Usage")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text(String(format: "$%.1f/$%.1f", Double(usedCredits) / 100.0, Double(monthlyLimit) / 100.0))
                        .font(.system(size: 16, weight: .bold))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(trackColor)
                            .frame(height: 6)

                        Capsule()
                            .fill(progressColor(utilization))
                            .frame(width: geometry.size.width * min(utilization, 100) / 100, height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(Int(utilization))% of monthly limit")
                    .font(.system(size: 11))
                    .foregroundColor(secondaryText)
            } else {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(secondaryText)
                    Text("Extra Usage")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(secondaryText)
                    Spacer()
                    Text("Disabled")
                        .font(.system(size: 13))
                        .foregroundColor(secondaryText)
                }
            }
        }
    }

    private func progressColor(_ utilization: Double) -> Color {
        if utilization > 90 {
            return Color(red: 0.9, green: 0.35, blue: 0.35)
        } else if utilization > 70 {
            return Color(red: 0.85, green: 0.65, blue: 0.34)
        } else {
            return Color(red: 0.42, green: 0.62, blue: 0.48)
        }
    }
}
