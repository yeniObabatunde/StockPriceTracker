//
//  PriceHeroCard.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct PriceHeroCard: View {
  let symbol: StockSymbol?

  @State private var flashScale: CGFloat = 1.0
  @State private var previousPrice: Double = 0

  private var isUp: Bool { (symbol?.changeDirection ?? .unchanged) == .up }
  private var accentColor: Color {
    guard let symbol else { return .white }
    if symbol.changeDirection == .up   { return Color(hex: "#00FF87") }
    if symbol.changeDirection == .down { return Color(hex: "#FF4444") }
    return Color.white.opacity(0.5)
  }

  var body: some View {
    VStack(spacing: 0) {
      priceRow
      accentLine
    }
    .background(cardBackground)
    .onChange(of: symbol?.currentPrice) { old, new in
      guard let old, let new, old != 0 else { return }
      withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
        flashScale = 1.04
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
          flashScale = 1.0
        }
      }
    }
  }

}

extension PriceHeroCard {
  @ViewBuilder
  private var priceRow: some View {
    HStack(alignment: .bottom) {
      leftColumn
      Spacer()
      rightColumn
    }
    .padding(20)
  }

  @ViewBuilder
  private var leftColumn: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(symbol?.companyName ?? "—")
        .font(.system(size: 13, weight: .regular))
        .foregroundColor(Color.white.opacity(0.45))

      Text(symbol?.formattedPrice ?? "$—")
        .font(.custom("Courier New", size: 40))
        .fontWeight(.bold)
        .monospacedDigit()
        .foregroundColor(.white)
        .scaleEffect(flashScale, anchor: .leading)
    }
  }

  @ViewBuilder
  private var rightColumn: some View {
    VStack(alignment: .trailing, spacing: 6) {
      Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
        .font(.system(size: 28, weight: .thin))
        .foregroundColor(accentColor)

      Text(symbol?.formattedChangePercent ?? "—")
        .font(.custom("Courier New", size: 16))
        .fontWeight(.bold)
        .monospacedDigit()
        .foregroundColor(accentColor)
    }
  }

  @ViewBuilder
  private var accentLine: some View {
    GeometryReader { _ in
      Rectangle()
        .fill(
          LinearGradient(
            colors: [accentColor.opacity(0.8), accentColor.opacity(0)],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .frame(height: 1)
    }
    .frame(height: 1)
  }

  private var cardBackground: some View {
    RoundedRectangle(cornerRadius: 6)
      .fill(Color(hex: "#0D1117"))
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(Color.white.opacity(0.07), lineWidth: 1)
      )
  }
}

#Preview {
  PriceHeroCard(symbol: StockSymbolSeed.all.first)
}
