//
//  StatCell.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct StatCell: View {
    let label: String
    let value: String
    var highlight: PriceChangeDirection? = nil

    private var valueColor: Color {
        switch highlight {
        case .up:        return Color(hex: "#00FF87")
        case .down:      return Color(hex: "#FF4444")
        default:         return .white
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.custom("Courier New", size: 9))
                .tracking(2)
                .foregroundColor(Color.white.opacity(0.3))
            Text(value)
                .font(.custom("Courier New", size: 15))
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: "#111820"))
    }
}

#Preview {
//    StatsGrid()
}
