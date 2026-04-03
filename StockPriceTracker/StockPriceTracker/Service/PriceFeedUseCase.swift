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
    private let priceRange: ClosedRange<Double>
    private let updateInterval: TimeInterval

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

    public init(
        socket: StockSocketService,
        store: StockPriceStoring,
        tickerPool: [String] = StockSymbolSeed.all.map(\.ticker),
        priceRange: ClosedRange<Double> = 50...3500,
        updateInterval: TimeInterval = 1.5
    ) {
        self.socket = socket
        self.store = store
        self.tickerPool = tickerPool
        self.priceRange = priceRange
        self.updateInterval = updateInterval
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
        sendRandomPriceUpdate()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: updateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.sendRandomPriceUpdate()
        }
    }

    private func sendRandomPriceUpdate() {
        guard let ticker = tickerPool.randomElement() else { return }
        let update = PriceUpdate(
            ticker: ticker,
            price: Double.random(in: priceRange),
            timestamp: .now
        )
        guard let data = try? encoder.encode(update),
              let json = String(data: data, encoding: .utf8) else { return }

        Task {
            try? await socket.send(json)
        }
    }

    func parse(message: String) -> PriceUpdate? {
        guard let data = message.data(using: .utf8) else { return nil }
        return try? decoder.decode(PriceUpdate.self, from: data)
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
      guard let update = parse(message: message) else {
          return
      }
      store.applyUpdate(update)
  }

    public func socketDidEncounterError(_ error: SocketError) {
        store.setConnectionState(.disconnected)
    }
  
}
