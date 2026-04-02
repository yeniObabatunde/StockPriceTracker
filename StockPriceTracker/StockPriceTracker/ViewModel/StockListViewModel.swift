//
//  StockListViewModel.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation
import Observation

@Observable
public final class StockListViewModel {

  public var sortedSymbols: [StockSymbol] {
    sort(symbols: store.symbols, by: selectedSort)
  }

  public var selectedSort: SortOption = .byPrice

  public var connectionState: ConnectionState {
    store.connectionState
  }

  public var isFeedActive: Bool {
    connectionState == .connected || connectionState == .connecting
  }

  private let store: StockPriceStoring
  private let priceFeed: PriceFeedManaging

  public init(store: StockPriceStoring, priceFeed: PriceFeedManaging) {
    self.store = store
    self.priceFeed = priceFeed
  }

  public func toggleFeed() {
    isFeedActive ? priceFeed.stopFeed() : priceFeed.startFeed()
  }

  public func selectSort(_ option: SortOption) {
    selectedSort = option
  }

  private func sort(symbols: [StockSymbol], by option: SortOption) -> [StockSymbol] {
    switch option {
      case .byPrice:
        return symbols.sorted { $0.currentPrice > $1.currentPrice }
      case .byPriceChange:
        return symbols.sorted { $0.priceChange > $1.priceChange }
    }
  }
}
