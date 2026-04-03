//
//  Storeprotocols.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation

public protocol StockPriceStoring: AnyObject {
  var symbols: [StockSymbol] { get }
  var connectionState: ConnectionState { get }

  @MainActor func applyUpdate(_ update: PriceUpdate)
  @MainActor func setConnectionState(_ state: ConnectionState)
  func symbol(for ticker: String) -> StockSymbol?
}

public protocol PriceFeedManaging: AnyObject {
  func startFeed()
  func stopFeed()
}

#if DEBUG
final class MockPriceFeedManaging: PriceFeedManaging {
  func startFeed() {}

  func stopFeed() {}
}
#endif
