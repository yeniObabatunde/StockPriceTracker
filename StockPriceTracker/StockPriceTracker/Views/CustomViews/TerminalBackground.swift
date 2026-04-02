//
//  TerminalBackground.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

import SwiftUI

struct TerminalBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "#080B0F")
                .ignoresSafeArea()

            Canvas { ctx, size in
                let spacing: CGFloat = 40
                var path = Path()
                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += spacing
                }
                ctx.stroke(path, with: .color(Color.white.opacity(0.025)), lineWidth: 0.5)
            }
            .ignoresSafeArea()
        }
    }
}
