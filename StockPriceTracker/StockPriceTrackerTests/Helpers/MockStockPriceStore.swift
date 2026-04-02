//
//  MockStockPriceStore.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

@testable import StockPriceTracker

final class MockStockPriceStore: StockPriceStoring {
  private(set) var appliedUpdates: [PriceUpdate] = []
  private(set) var connectionStateChanges: [ConnectionState] = []

  var symbols: [StockSymbol]
  var connectionState: ConnectionState = .disconnected

  init(symbols: [StockSymbol] = StockSymbolSeed.all) {
    self.symbols = symbols
  }

  func applyUpdate(_ update: PriceUpdate) {
    appliedUpdates.append(update)
    guard let index = symbols.firstIndex(where: { $0.ticker == update.ticker }) else { return }
    symbols[index].previousPrice = symbols[index].currentPrice
    symbols[index].currentPrice  = update.price
    symbols[index].lastUpdated   = update.timestamp
  }

  func setConnectionState(_ state: ConnectionState) {
    connectionStateChanges.append(state)
    connectionState = state
  }

  func symbol(for ticker: String) -> StockSymbol? {
    symbols.first { $0.ticker == ticker }
  }

  var lastAppliedUpdate: PriceUpdate? { appliedUpdates.last }
  var lastConnectionState: ConnectionState? { connectionStateChanges.last }
}

final class MockPriceFeedManaging: PriceFeedManaging {
  private(set) var startCallCount = 0
  private(set) var stopCallCount  = 0

  func startFeed() { startCallCount += 1 }
  func stopFeed()  { stopCallCount  += 1 }
}
