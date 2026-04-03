//
//  PriceFeedUseCase.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation

public final class PriceFeedUseCase: PriceFeedManaging {

    private let socket: StockSocketService
    private let store: StockPriceStoring
    private let tickerPool: [String]
    private let updateInterval: TimeInterval
    private var lastPrices: [String: Double] = [:]

    private var updateTimer: Timer?

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let seedPrices: [String: Double] = [
        "AAPL": 189.00, "GOOG": 175.00, "TSLA": 175.00, "AMZN": 185.00,
        "MSFT": 415.00, "NVDA": 875.00, "META": 505.00, "NFLX": 630.00,
        "BRKB": 415.00, "JPM":  200.00, "V":    275.00, "UNH":  495.00,
        "JNJ":  155.00, "WMT":  175.00, "MA":   475.00, "PG":   165.00,
        "HD":   375.00, "DIS":   95.00, "PYPL":  65.00, "ADBE": 475.00,
        "CRM":  300.00, "INTC":  30.00, "AMD":  165.00, "QCOM": 165.00,
        "SPOT": 355.00
    ]

    public init(
        socket: StockSocketService,
        store: StockPriceStoring,
        tickerPool: [String] = StockSymbolSeed.all.map(\.ticker),
        updateInterval: TimeInterval = 4.5
    ) {
        self.socket = socket
        self.store = store
        self.tickerPool = tickerPool
        self.updateInterval = updateInterval
        self.lastPrices = seedPrices
        self.socket.listener = self
    }

    public func startFeed() {
        socket.connect()
    }

    public func stopFeed() {
        updateTimer?.invalidate()
        updateTimer = nil
        socket.disconnect()
    }

    private func startSendingUpdates() {
        sendBatchPriceUpdate()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: updateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.sendBatchPriceUpdate()
        }
    }

    private func sendBatchPriceUpdate() {
        let updates = tickerPool.map { ticker -> PriceUpdate in
            let last = lastPrices[ticker] ?? seedPrices[ticker] ?? 100.0
            let next = nextPrice(from: last)
            lastPrices[ticker] = next
            return PriceUpdate(ticker: ticker, price: next, timestamp: .now)
        }

        guard let data = try? encoder.encode(updates),
              let json = String(data: data, encoding: .utf8) else { return }

        Task {
            try? await socket.send(json)
        }
    }

    private func nextPrice(from last: Double) -> Double {
        let maxMovePercent = 0.02
        let change = Double.random(in: -maxMovePercent...maxMovePercent)
        let next = last * (1 + change)
        return (next * 100).rounded() / 100
    }

    func parse(message: String) -> [PriceUpdate]? {
        guard let data = message.data(using: .utf8) else { return nil }
        return try? decoder.decode([PriceUpdate].self, from: data)
    }
}

extension PriceFeedUseCase: SocketEventListening {

    public func socketDidConnect() {
        store.setConnectionState(.connected)
        startSendingUpdates()
    }

    public func socketDidDisconnect(reason: String?) {
        updateTimer?.invalidate()
        updateTimer = nil
        store.setConnectionState(.disconnected)
    }

  public func socketDidReceiveMessage(_ message: String) {
    guard let updates = parse(message: message) else {
      return
    }
    store.applyBatchUpdate(updates)
  }

    public func socketDidEncounterError(_ error: SocketError) {
        store.setConnectionState(.disconnected)
    }
}
