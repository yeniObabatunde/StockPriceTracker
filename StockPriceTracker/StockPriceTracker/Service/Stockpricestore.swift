//
//  StockPriceStoring.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Observation

@Observable
public final class StockPriceStore: StockPriceStoring {

    public private(set) var symbols: [StockSymbol]
    public private(set) var connectionState: ConnectionState = .disconnected
  private let maxHistoryPoints = 40
  private var priceHistories: [String: [Double]] = [:]

    public init(symbols: [StockSymbol] = StockSymbolSeed.all) {
        self.symbols = symbols
    }

  public func applyUpdate(_ update: PriceUpdate) {
      guard let index = symbols.firstIndex(where: { $0.ticker == update.ticker }) else { return }
      symbols[index].previousPrice = symbols[index].currentPrice
      symbols[index].currentPrice  = update.price
      symbols[index].lastUpdated   = update.timestamp
      appendToHistory(ticker: update.ticker, price: update.price)
  }

  public func applyBatchUpdate(_ updates: [PriceUpdate]) {
      for update in updates {
          guard let index = symbols.firstIndex(where: { $0.ticker == update.ticker }) else { continue }
          symbols[index].previousPrice = symbols[index].currentPrice
          symbols[index].currentPrice  = update.price
          symbols[index].lastUpdated   = update.timestamp
          appendToHistory(ticker: update.ticker, price: update.price)
      }
  }

  private func appendToHistory(ticker: String, price: Double) {
      var history = priceHistories[ticker] ?? []
      history.append(price)
      if history.count > maxHistoryPoints { history.removeFirst() }
      priceHistories[ticker] = history
  }

    public func setConnectionState(_ state: ConnectionState) {
        connectionState = state
    }

  public func priceHistory(for ticker: String) -> [Double] {
      priceHistories[ticker] ?? []
  }

  public func symbol(for ticker: String) -> StockSymbol? {
    symbols.first { $0.ticker == ticker }
  }
}
