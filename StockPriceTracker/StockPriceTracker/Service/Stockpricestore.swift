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

    public init(symbols: [StockSymbol] = StockSymbolSeed.all) {
        self.symbols = symbols
    }

    public func applyUpdate(_ update: PriceUpdate) {
        guard let index = symbols.firstIndex(where: { $0.ticker == update.ticker }) else { return }
        symbols[index].previousPrice = symbols[index].currentPrice
        symbols[index].currentPrice  = update.price
        symbols[index].lastUpdated   = update.timestamp
    }

    public func setConnectionState(_ state: ConnectionState) {
        connectionState = state
    }

    public func symbol(for ticker: String) -> StockSymbol? {
        symbols.first { $0.ticker == ticker }
    }
}
