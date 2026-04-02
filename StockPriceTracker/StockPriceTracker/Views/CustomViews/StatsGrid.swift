//
//  StatsGrid.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct StatsGrid: View {
    let symbol: StockSymbol

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATISTICS")
                .font(.custom("Courier New", size: 10))
                .fontWeight(.bold)
                .tracking(3)
                .foregroundColor(Color.white.opacity(0.3))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 1) {
                StatCell(label: "CURRENT", value: symbol.formattedPrice)
                StatCell(label: "PREV CLOSE", value: symbol.previousPrice > 0 ? String(format: "$%.2f", symbol.previousPrice) : "—")
                StatCell(label: "CHANGE", value: String(format: "%+.2f", symbol.priceChange), highlight: symbol.changeDirection)
                StatCell(label: "CHANGE %", value: symbol.formattedChangePercent, highlight: symbol.changeDirection)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "#0D1117"))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

#Preview {
  StatsGrid(symbol: .init(ticker: "0.0", companyName: "ABC", description: "some test"))
}
