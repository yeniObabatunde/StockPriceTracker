//
//  PriceUpdate.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import Foundation

public struct PriceUpdate: Equatable, Sendable, Codable {
  public let ticker: String
  public let price: Double
  public let timestamp: Date

  public init(ticker: String, price: Double, timestamp: Date = .now) {
    self.ticker = ticker
    self.price = price
    self.timestamp = timestamp
  }
}
