//
//  HeaderBar.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

import SwiftUI

struct HeaderBar: View {
    let connectionState: ConnectionState
    let isFeedActive: Bool
    let onToggleFeed: () -> Void

    @State private var pulse = false

    var body: some View {
        HStack(alignment: .center) {
            titleStack
            Spacer()
            controlStack
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color(hex: "#080B0F"))
        .onAppear { pulse = true }
        .onChange(of: connectionState) { _, _ in pulse = true }
    }

    @ViewBuilder
    private var titleStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("MARKET FEED")
                .font(.custom("Courier New", size: 11))
                .fontWeight(.bold)
                .tracking(4)
                .foregroundColor(Color(hex: "#4A90A4"))

            Text("LIVE PRICES")
                .font(.custom("Courier New", size: 22))
                .fontWeight(.bold)
                .tracking(2)
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private var controlStack: some View {
        VStack(alignment: .trailing, spacing: 8) {
            connectionIndicator
            toggleButton
        }
    }

    @ViewBuilder
    private var connectionIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(connectionState == .connected ? Color(hex: "#00FF87") : Color(hex: "#FF4444"))
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .animation(
                    connectionState == .connected
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: pulse
                )

            Text(connectionState == .connected ? "LIVE" : connectionState == .connecting ? "CONNECTING" : "OFFLINE")
                .font(.custom("Courier New", size: 10))
                .fontWeight(.bold)
                .tracking(2)
                .foregroundColor(connectionState == .connected ? Color(hex: "#00FF87") : Color(hex: "#FF4444"))
        }
    }

    @ViewBuilder
    private var toggleButton: some View {
        Button(action: onToggleFeed) {
            Text(isFeedActive ? "■ STOP" : "▶ START")
                .font(.custom("Courier New", size: 11))
                .fontWeight(.bold)
                .tracking(2)
                .foregroundColor(isFeedActive ? Color(hex: "#FF4444") : Color(hex: "#00FF87"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(
                            isFeedActive ? Color(hex: "#FF4444") : Color(hex: "#00FF87"),
                            lineWidth: 1
                        )
                )
        }
    }
}
