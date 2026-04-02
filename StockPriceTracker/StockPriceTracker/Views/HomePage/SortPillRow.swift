//
//  SortPillRow.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

import SwiftUI

struct SortPillRow: View {
  let selected: SortOption
  let onSelect: (SortOption) -> Void

  var body: some View {
    HStack(spacing: 8) {
      sortLabel
      sortPills
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(Color(hex: "#0D1117"))
    .overlay(
      Rectangle()
        .frame(height: 1)
        .foregroundColor(Color.white.opacity(0.06)),
      alignment: .bottom
    )
  }

  @ViewBuilder
  private var sortLabel: some View {
    Text("SORT BY")
      .font(.custom("Courier New", size: 9))
      .tracking(3)
      .foregroundColor(Color.white.opacity(0.3))
  }

  @ViewBuilder
  private var sortPills: some View {
    ForEach(SortOption.allCases, id: \.self) { option in
      Button { onSelect(option) } label: {
        Text(option.rawValue.uppercased())
          .font(.custom("Courier New", size: 10))
          .fontWeight(.bold)
          .tracking(2)
          .foregroundColor(selected == option ? Color(hex: "#080B0F") : Color.white.opacity(0.5))
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(
            RoundedRectangle(cornerRadius: 3)
              .fill(selected == option ? Color(hex: "#4A90A4") : Color.clear)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 3)
              .stroke(
                selected == option ? Color.clear : Color.white.opacity(0.15),
                lineWidth: 1
              )
          )
      }
      .animation(.easeInOut(duration: 0.2), value: selected)
    }
  }
}

#Preview {
  SortPillRow(selected: .byPrice, onSelect: {_ in 

  })
}
