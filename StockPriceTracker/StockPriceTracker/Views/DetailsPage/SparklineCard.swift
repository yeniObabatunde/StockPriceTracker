//
//  SparklineCard.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct SparklineCard: View {
  let history: [Double]

  private var minPrice: Double { history.min() ?? 0 }
  private var maxPrice: Double { history.max() ?? 1 }
  private var isUp: Bool { (history.last ?? 0) >= (history.first ?? 0) }
  private var lineColor: Color { isUp ? Color(hex: "#00FF87") : Color(hex: "#FF4444") }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      header
      sparklineChart
    }
    .padding(20)
    .background(cardBackground)
    .animation(.easeInOut(duration: 0.3), value: history.count)
  }

  @ViewBuilder
  private var header: some View {
    HStack {
      Text("PRICE HISTORY")
        .font(.custom("Courier New", size: 10))
        .fontWeight(.bold)
        .tracking(3)
        .foregroundColor(Color.white.opacity(0.3))

      Spacer()

      Text("\(history.count) ticks")
        .font(.custom("Courier New", size: 10))
        .tracking(2)
        .foregroundColor(Color.white.opacity(0.2))
    }
  }

  @ViewBuilder
  private var sparklineChart: some View {
    GeometryReader { geo in
      ZStack(alignment: .bottomLeading) {
        fillGradient
        sparklineLine
        latestPriceDot(in: geo)
      }
    }
    .frame(height: 80)
  }

  @ViewBuilder
  private var fillGradient: some View {
    SparklineFillShape(history: history, min: minPrice, max: maxPrice)
      .fill(
        LinearGradient(
          colors: [lineColor.opacity(0.25), lineColor.opacity(0.0)],
          startPoint: .top,
          endPoint: .bottom
        )
      )
  }

  @ViewBuilder
  private var sparklineLine: some View {
    SparklineShape(history: history, min: minPrice, max: maxPrice)
      .stroke(lineColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
  }

  @ViewBuilder
  private func latestPriceDot(in geo: GeometryProxy) -> some View {
    if let last = history.last, history.count > 1 {
      let x = geo.size.width
      let range = maxPrice - minPrice
      let normalised = range > 0 ? (last - minPrice) / range : 0.5
      let y = geo.size.height * (1 - normalised)

      Circle()
        .fill(lineColor)
        .frame(width: 6, height: 6)
        .position(x: x - 3, y: y)

      Circle()
        .fill(lineColor.opacity(0.3))
        .frame(width: 12, height: 12)
        .position(x: x - 3, y: y)
    }
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
  SparklineCard(history: [100, 102, 101, 105, 103, 107, 110])
    .padding()
}
