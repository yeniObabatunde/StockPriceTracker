//
//  Stockdetailviewmodel.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation
import Observation

@Observable
public final class StockDetailViewModel {
  
  public var symbol: StockSymbol? {
    store.symbol(for: ticker)
  }
  
  public let ticker: String
  private let store: StockPriceStoring
  
  public init(ticker: String, store: StockPriceStoring) {
    self.ticker = ticker
    self.store = store
  }
  
  public var navigationTitle: String {
    symbol.map { "\($0.ticker) — \($0.companyName)" } ?? ticker
  }
}

#if DEBUG
final class MockStockPriceStore: StockPriceStoring {
  var symbols: [StockSymbol] = [
    .init(
      ticker: "AAPL",
      companyName: "Apple Inc.",
      description: "Designs and sells consumer electronics and software."
    )
  ]
  
  var connectionState: ConnectionState = .connected
  
  func applyUpdate(_ update: PriceUpdate) {}
  func setConnectionState(_ state: ConnectionState) {}
  
  func symbol(for ticker: String) -> StockSymbol? {
    symbols.first { $0.ticker == ticker }
  }
}
#endif
