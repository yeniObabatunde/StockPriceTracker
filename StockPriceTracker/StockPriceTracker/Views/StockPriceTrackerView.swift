//
//  StockPriceTrackerView.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct StockPriceTrackerView: View {

  private let store   = StockPriceStore()
  private let socket  = LiveStockSocketService()

  @State private var useCase: PriceFeedUseCase?

  var body: some View {
    Group {
      if let feed = useCase {
        StockListView(
          viewModel: StockListViewModel(store: store, priceFeed: feed),
          detailVMFactory: { ticker in
            StockDetailViewModel(ticker: ticker, store: store)
          }
        )
      }
    }
    .onAppear {
      guard useCase == nil else { return }
      let feed = PriceFeedUseCase(socket: socket, store: store, updateInterval: 1.5)
      useCase = feed
      feed.startFeed()
    }
    .onDisappear {
      useCase?.stopFeed()
    }
  }
}

#Preview {
  StockPriceTrackerView()
}
