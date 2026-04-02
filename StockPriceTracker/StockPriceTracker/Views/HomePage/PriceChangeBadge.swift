//
//  PriceChangeBadge.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

import SwiftUI

struct PriceChangeBadge: View {
  let symbol: StockSymbol

  private var isUp: Bool { symbol.changeDirection == .up }
  private var isDown: Bool { symbol.changeDirection == .down }

  private var badgeColor: Color {
    if isUp   { return Color(hex: "#00FF87") }
    if isDown { return Color(hex: "#FF4444") }
    return Color.white.opacity(0.3)
  }

  private var arrow: String {
    if isUp   { return "▲" }
    if isDown { return "▼" }
    return "—"
  }

  var body: some View {
    HStack(spacing: 3) {
      Text(arrow)
        .font(.system(size: 9))
      Text(symbol.formattedChangePercent)
        .font(.custom("Courier New", size: 11))
        .fontWeight(.bold)
        .monospacedDigit()
    }
    .foregroundColor(badgeColor)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 3)
        .fill(badgeColor.opacity(0.1))
    )
    .frame(width: 88, alignment: .trailing)
    .animation(.easeInOut(duration: 0.2), value: symbol.currentPrice)
  }
}

#Preview {
  PriceChangeBadge(symbol: StockSymbolSeed.all.first!)
}
