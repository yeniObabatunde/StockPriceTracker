//
//  StockDetailView.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct StockDetailView: View {

  @State private var viewModel: StockDetailViewModel
  @Environment(\.dismiss) private var dismiss

  @State private var priceHistory: [Double] = []
  @State private var appearedOnce = false
  @State private var headerVisible = false
  @State private var statsVisible = false
  @State private var chartVisible = false

  private let maxHistoryPoints = 40

  init(viewModel: StockDetailViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    ZStack {
      TerminalBackground()

      VStack(spacing: 0) {
        header
        scrollContent
      }
    }
    .navigationBarHidden(true)
    .onAppear {
      guard !appearedOnce else { return }
      appearedOnce = true
      animateIn()
      if let price = viewModel.symbol?.currentPrice, price > 0 {
        priceHistory = [price]
      }
    }
    .onChange(of: viewModel.symbol?.currentPrice) { _, newPrice in
      guard let newPrice, newPrice > 0 else { return }
      priceHistory.append(newPrice)
      if priceHistory.count > maxHistoryPoints {
        priceHistory.removeFirst()
      }
    }
  }

  @ViewBuilder
  private var header: some View {
    DetailHeaderBar(
      ticker: viewModel.ticker,
      symbol: viewModel.symbol,
      onBack: { dismiss() }
    )
    .opacity(headerVisible ? 1 : 0)
    .offset(y: headerVisible ? 0 : -12)
  }

  @ViewBuilder
  private var scrollContent: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 20) {
        priceHero
        sparklineChart
        symbolStats
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)
      .padding(.bottom, 40)
    }
  }

  @ViewBuilder
  private var priceHero: some View {
    PriceHeroCard(symbol: viewModel.symbol)
      .opacity(headerVisible ? 1 : 0)
      .offset(y: headerVisible ? 0 : 16)
  }

  @ViewBuilder
  private var sparklineChart: some View {
    if !priceHistory.isEmpty {
      SparklineCard(history: priceHistory)
        .opacity(chartVisible ? 1 : 0)
        .offset(y: chartVisible ? 0 : 20)
    }
  }

  @ViewBuilder
  private var symbolStats: some View {
    if let symbol = viewModel.symbol {
      StatsGrid(symbol: symbol)
        .opacity(statsVisible ? 1 : 0)
        .offset(y: statsVisible ? 0 : 20)

      DescriptionCard(description: symbol.description)
        .opacity(statsVisible ? 1 : 0)
        .offset(y: statsVisible ? 0 : 20)
    }
  }

  private func animateIn() {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
      headerVisible = true
    }
    withAnimation(.spring(response: 0.45, dampingFraction: 0.85).delay(0.12)) {
      chartVisible = true
    }
    withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.22)) {
      statsVisible = true
    }
  }
}

#Preview {
  StockDetailView(viewModel: .init(ticker: "AAPL", store: MockStockPriceStore()))
}
