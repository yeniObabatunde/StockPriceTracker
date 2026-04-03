//
//  SparklineWaitingView.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import SwiftUI

struct SparklineWaitingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
                .frame(height: 120)

            Text("COLLECTING PRICE HISTORY...")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.gray)
                .tracking(1.5)
        }
    }
}

#Preview {
    SparklineWaitingView()
}
