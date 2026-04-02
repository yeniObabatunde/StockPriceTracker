//
//  DetailHeaderBar.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct DetailHeaderBar: View {
  let ticker: String
  let symbol: StockSymbol?
  let onBack: () -> Void

  var body: some View {
      HStack {
        chevronBackButton
        tickerView
        marketTextView
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .background(Color(hex: "#080B0F"))
      .overlay(
          Rectangle()
              .frame(height: 1)
              .foregroundColor(Color.white.opacity(0.06)),
          alignment: .bottom
      )
  }
}

extension DetailHeaderBar {

  @ViewBuilder
  private var chevronBackButton: some View {
    Button(action: onBack) {
        HStack(spacing: 6) {
            Image(systemName: "chevron.left")
                .font(.system(size: 12, weight: .bold))
            Text("MARKET")
                .font(.custom("Courier New", size: 11))
                .fontWeight(.bold)
                .tracking(2)
        }
        .foregroundColor(Color(hex: "#4A90A4"))
    }

    Spacer()
  }

  @ViewBuilder
  private var tickerView: some View {
    Text(ticker)
        .font(.custom("Courier New", size: 16))
        .fontWeight(.bold)
        .tracking(3)
        .foregroundColor(.white)

    Spacer()
  }

  @ViewBuilder
  private var marketTextView: some View {
    Text("MARKET")
        .font(.custom("Courier New", size: 11))
        .tracking(2)
        .opacity(0)
  }
}

#Preview {
  DetailHeaderBar(ticker: "", symbol: StockSymbolSeed.all.first, onBack: {
    
  })
}
