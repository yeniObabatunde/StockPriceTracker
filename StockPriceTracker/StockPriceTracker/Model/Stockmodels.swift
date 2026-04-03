//
//  Stockmodels.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation

public struct StockSymbol: Identifiable, Equatable, Sendable {
    public let id: String
    public let ticker: String
    public let companyName: String
    public let description: String
    public var currentPrice: Double
    public var previousPrice: Double
    public var lastUpdated: Date

    public init(
        ticker: String,
        companyName: String,
        description: String,
        currentPrice: Double = 0,
        previousPrice: Double = 0,
        lastUpdated: Date = .now
    ) {
        self.id = ticker
        self.ticker = ticker
        self.companyName = companyName
        self.description = description
        self.currentPrice = currentPrice
        self.previousPrice = previousPrice
        self.lastUpdated = lastUpdated
    }
}

public extension StockSymbol {
    var priceChange: Double {
        currentPrice - previousPrice
    }

    var changeDirection: PriceChangeDirection {
        if priceChange > 0 { return .up }
        if priceChange < 0 { return .down }
        return .unchanged
    }

    var formattedChangePercent: String {
        guard previousPrice > 0 else { return "—" }
        let pct = (priceChange / previousPrice) * 100
        return String(format: "%+.2f%%", pct)
    }

    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }
}

public enum PriceChangeDirection: String, Equatable, Sendable {
    case up
    case down
    case unchanged
}
