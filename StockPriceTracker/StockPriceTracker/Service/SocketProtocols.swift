//
//  SocketProtocols.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import Foundation

public protocol Connectable: AnyObject {
  func connect()
  func disconnect()
  var connectionState: ConnectionState { get }
}

public protocol MessageSendable: AnyObject {
  func send(_ message: String) async throws
}

public protocol SocketEventListening: AnyObject {
  @MainActor func socketDidConnect()
  @MainActor func socketDidDisconnect(reason: String?)
  @MainActor func socketDidReceiveMessage(_ message: String)
  @MainActor func socketDidEncounterError(_ error: SocketError)
}

public protocol StockSocketService: Connectable, MessageSendable {
  var listener: SocketEventListening? { get set }
}

public enum ConnectionState: Equatable {
  case disconnected
  case connecting
  case connected
}

public enum SocketError: Error, Equatable {
  case connectionFailed(String)
  case messageDecodingFailed(String)
  case urlError(String)
  case unexpectedDisconnect
  case unknown(String)
}
