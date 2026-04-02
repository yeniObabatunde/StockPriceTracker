//
//  StockRowView.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

import SwiftUI

struct StockRowView: View {
    let symbol: StockSymbol

    @State private var flashColor: Color = .clear

    var body: some View {
        HStack(spacing: 0) {
            tickerInfo
            PriceChangeBadge(symbol: symbol)
            Spacer().frame(width: 12)
            priceLabel
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(rowBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.04)),
            alignment: .bottom
        )
        .onChange(of: symbol.currentPrice) { oldPrice, newPrice in
            guard oldPrice != 0 else { return }
            withAnimation(.easeIn(duration: 0.05)) {
                flashColor = newPrice > oldPrice
                    ? Color(hex: "#00FF87").opacity(0.12)
                    : Color(hex: "#FF4444").opacity(0.12)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeOut(duration: 0.4)) {
                    flashColor = .clear
                }
            }
        }
    }

    @ViewBuilder
    private var tickerInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(symbol.ticker)
                .font(.custom("Courier New", size: 15))
                .fontWeight(.bold)
                .tracking(1)
                .foregroundColor(.white)

            Text(symbol.companyName)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.white.opacity(0.35))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var priceLabel: some View {
        Text(symbol.formattedPrice)
            .font(.custom("Courier New", size: 17))
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundColor(.white)
            .frame(width: 100, alignment: .trailing)
    }

    private var rowBackground: some View {
        ZStack {
            Color(hex: "#0D1117")
            flashColor
        }
    }
}

#Preview {
  StockRowView(symbol: StockSymbolSeed.all.first!)
}
