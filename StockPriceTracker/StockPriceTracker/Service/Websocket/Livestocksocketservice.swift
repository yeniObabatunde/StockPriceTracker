//
//  Livestocksocketservice.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation

public final class LiveStockSocketService: NSObject, StockSocketService {
  
  public weak var listener: SocketEventListening?
  
  public private(set) var connectionState: ConnectionState = .disconnected {
    didSet {
      guard connectionState != oldValue else { return }
      notifyConnectionChange()
    }
  }
  
  private let session: URLSession
  private var webSocketTask: URLSessionWebSocketTask?

  private var pingTimer: Timer?
  private let pingInterval: TimeInterval
  
  private var reconnectAttempt = 0
  private var intentionalDisconnect = false
  private var reconnectWorkItem: DispatchWorkItem?
  private let maxReconnectDelay: TimeInterval = 16

  public init(
    session: URLSession = .shared,
    pingInterval: TimeInterval = 15
  ) {
    self.session = session
    self.pingInterval = pingInterval
  }
  
  public func connect() {
    guard connectionState == .disconnected else { return }
    intentionalDisconnect = false
    openSocket()
  }
  
  public func disconnect() {
    intentionalDisconnect = true
    reconnectAttempt = 0
    cancelReconnect()
    tearDownSocket(closeCode: .normalClosure)
    connectionState = .disconnected
  }
  
  public func send(_ message: String) async throws {
    guard connectionState == .connected, let task = webSocketTask else {
      throw SocketError.connectionFailed("Cannot send — socket is not connected.")
    }
    try await task.send(.string(message))
  }
  
  private func openSocket() {
    connectionState = .connecting
    guard let url =  URL(string: Constants.App.socketURL) else {
      return
    }
    let task = session.webSocketTask(with: url)
    webSocketTask = task
    task.delegate = self
    task.resume()
    scheduleReceive()
  }
  
  private func tearDownSocket(closeCode: URLSessionWebSocketTask.CloseCode) {
    stopPingTimer()
    webSocketTask?.cancel(with: closeCode, reason: nil)
    webSocketTask = nil
  }
  
  private func scheduleReceive() {
    webSocketTask?.receive { [weak self] result in
      guard let self else { return }
      switch result {
        case .success(let message):
          self.handle(message: message)
          self.scheduleReceive()
        case .failure(_):
          self.handleUnexpectedDisconnect()
      }
    }
  }
  
  private func handle(message: URLSessionWebSocketTask.Message) {
    switch message {
      case .string(let text):
        DispatchQueue.main.async { self.listener?.socketDidReceiveMessage(text) }
      case .data(let data):
        guard let text = String(data: data, encoding: .utf8) else {
          DispatchQueue.main.async {
            self.listener?.socketDidEncounterError(
              .messageDecodingFailed("Binary data could not be decoded as UTF-8")
            )
          }
          return
        }
        DispatchQueue.main.async { self.listener?.socketDidReceiveMessage(text) }
      @unknown default:
        break
    }
  }
  
  private func startPingTimer() {
    stopPingTimer()
    pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
      self?.sendPing()
    }
  }
  
  private func stopPingTimer() {
    pingTimer?.invalidate()
    pingTimer = nil
  }
  
  private func sendPing() {
    webSocketTask?.sendPing { [weak self] error in
      guard let self else { return }
      if let _ = error {
        self.handleUnexpectedDisconnect()
      }
    }
  }
  
  private func handleUnexpectedDisconnect() {
    guard !intentionalDisconnect else { return }
    
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard self.connectionState != .connecting else { return }
      self.tearDownSocket(closeCode: .abnormalClosure)
      self.connectionState = .disconnected
      self.scheduleReconnect()
    }
  }
  
  private func scheduleReconnect() {
    cancelReconnect()
    let delay = min(pow(2.0, Double(reconnectAttempt)), maxReconnectDelay)
    reconnectAttempt += 1
    
    let item = DispatchWorkItem { [weak self] in
      guard let self, !self.intentionalDisconnect else { return }
      self.openSocket()
    }
    reconnectWorkItem = item
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
  }
  
  private func cancelReconnect() {
    reconnectWorkItem?.cancel()
    reconnectWorkItem = nil
  }
  
  private func notifyConnectionChange() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      switch self.connectionState {
        case .connected:    self.listener?.socketDidConnect()
        case .disconnected: self.listener?.socketDidDisconnect(reason: nil)
        case .connecting:   break
      }
    }
  }
}

extension LiveStockSocketService: URLSessionWebSocketDelegate {
  
  public func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didOpenWithProtocol protocol: String?
  ) {
    reconnectAttempt = 0
    connectionState = .connected
    startPingTimer()
  }
  
  public func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) {
    _ = reason.flatMap { String(data: $0, encoding: .utf8) }
    stopPingTimer()
    connectionState = .disconnected
    
    if closeCode != .normalClosure {
      handleUnexpectedDisconnect()
    }
  }
}
