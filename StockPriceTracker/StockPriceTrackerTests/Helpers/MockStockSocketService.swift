//
//  MockStockSocketService.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

@testable import StockPriceTracker

final class MockStockSocketService: StockSocketService {

  private(set) var connectCallCount = 0
  private(set) var disconnectCallCount = 0
  private(set) var sentMessages: [String] = []
  weak var listener: SocketEventListening?

  var stubbedConnectionState: ConnectionState = .disconnected
  var sendShouldThrow: Bool = false
  var connectionState: ConnectionState { stubbedConnectionState }

  func connect() {
    connectCallCount += 1
    stubbedConnectionState = .connected
    Task { @MainActor [weak self] in
      self?.listener?.socketDidConnect()
    }
  }

  func disconnect() {
    disconnectCallCount += 1
    stubbedConnectionState = .disconnected
    Task { @MainActor [weak self] in
      self?.listener?.socketDidDisconnect(reason: nil)
    }
  }

  func send(_ message: String) async throws {
    if sendShouldThrow { throw SocketError.connectionFailed("Mock send error") }
    sentMessages.append(message)
    await MainActor.run { [weak self] in
      self?.listener?.socketDidReceiveMessage(message)
    }
  }

  func simulateError(_ error: SocketError) {
    Task { @MainActor [weak self] in
      self?.listener?.socketDidEncounterError(error)
    }
  }

  func simulateInboundMessage(_ message: String) {
    Task { @MainActor [weak self] in
      self?.listener?.socketDidReceiveMessage(message)
    }
  }
}
