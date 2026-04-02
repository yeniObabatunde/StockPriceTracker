//
//  StockListView.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct StockListView: View {

  @State private var viewModel: StockListViewModel
  private let detailVMFactory: (String) -> StockDetailViewModel

  init(viewModel: StockListViewModel, detailVMFactory: @escaping (String) -> StockDetailViewModel) {
    _viewModel = State(initialValue: viewModel)
    self.detailVMFactory = detailVMFactory
  }

  var body: some View {
    NavigationStack {
      ZStack {
        TerminalBackground()

        VStack(spacing: 0) {
          HeaderBar(
            connectionState: viewModel.connectionState,
            isFeedActive: viewModel.isFeedActive,
            onToggleFeed: { viewModel.toggleFeed() }
          )
          SortPillRow(
            selected: viewModel.selectedSort,
            onSelect: { viewModel.selectSort($0) }
          )
          stockList
        }
      }
      .navigationBarHidden(true)
      .navigationDestination(for: String.self) { ticker in
        StockDetailView(viewModel: detailVMFactory(ticker))
      }
    }
  }

  @ViewBuilder
  private var stockList: some View {
    ScrollView {
      LazyVStack(spacing: 1) {
        ForEach(viewModel.sortedSymbols) { symbol in
          NavigationLink(value: symbol.ticker) {
            StockRowView(symbol: symbol)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.bottom, 32)
    }
  }
}

#Preview {
  StockListView.preview()
}

#if DEBUG
extension StockListView {
  static func preview() -> some View {
    StockListView(
      viewModel: .init(store: MockStockPriceStore(), priceFeed: MockPriceFeedManaging()),
      detailVMFactory: { ticker in .init(ticker: ticker, store: MockStockPriceStore()) }
    )
  }
}
#endif
