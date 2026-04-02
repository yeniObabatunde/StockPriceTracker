//
//  DescriptionCard.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct DescriptionCard: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
          aboutText
          descriptionView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

extension DescriptionCard {
  @ViewBuilder
  private var aboutText: some View {
    Text("ABOUT")
        .font(.custom("Courier New", size: 10))
        .fontWeight(.bold)
        .tracking(3)
        .foregroundColor(Color.white.opacity(0.3))
  }

  @ViewBuilder
  private var descriptionView: some View {
    Text(description)
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(Color.white.opacity(0.6))
        .lineSpacing(5)
  }

}

#Preview {
  DescriptionCard(description: "New")
}
