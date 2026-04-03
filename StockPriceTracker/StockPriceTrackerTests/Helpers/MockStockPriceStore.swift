//
//  MockStockPriceStore.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 02/04/2026.
//

@testable import StockPriceTracker

final class MockStockPriceStore: StockPriceStoring {

  private(set) var batchUpdates: [[PriceUpdate]] = []
  private(set) var connectionStateChanges: [ConnectionState] = []
  private var priceHistories: [String: [Double]] = [:]
  var symbols: [StockSymbol]
  var connectionState: ConnectionState = .disconnected

  private let maxHistoryPoints = 40

  init(symbols: [StockSymbol] = StockSymbolSeed.all) {
    self.symbols = symbols
  }

  func applyUpdate(_ update: PriceUpdate) {
    applyBatchUpdate([update])
  }

  func applyBatchUpdate(_ updates: [PriceUpdate]) {
    batchUpdates.append(updates)
    for update in updates {
      guard let index = symbols.firstIndex(where: { $0.ticker == update.ticker }) else { continue }
      symbols[index].previousPrice = symbols[index].currentPrice
      symbols[index].currentPrice  = update.price
      symbols[index].lastUpdated   = update.timestamp
      appendToHistory(ticker: update.ticker, price: update.price)
    }
  }

  func setConnectionState(_ state: ConnectionState) {
    connectionStateChanges.append(state)
    connectionState = state
  }

  func symbol(for ticker: String) -> StockSymbol? {
    symbols.first { $0.ticker == ticker }
  }

  func priceHistory(for ticker: String) -> [Double] {
    priceHistories[ticker] ?? []
  }

  private func appendToHistory(ticker: String, price: Double) {
    var history = priceHistories[ticker] ?? []
    history.append(price)
    if history.count > maxHistoryPoints { history.removeFirst() }
    priceHistories[ticker] = history
  }

  // Convenience helpers
  var allAppliedUpdates: [PriceUpdate] { batchUpdates.flatMap { $0 } }
  var lastBatch: [PriceUpdate]?        { batchUpdates.last }
  var lastAppliedUpdate: PriceUpdate?  { allAppliedUpdates.last }
  var lastConnectionState: ConnectionState? { connectionStateChanges.last }
}

final class MockPriceFeedManaging: PriceFeedManaging {
  private(set) var startCallCount = 0
  private(set) var stopCallCount  = 0

  func startFeed() { startCallCount += 1 }
  func stopFeed()  { stopCallCount  += 1 }
}
