//
//  PriceFeedUseCaseTests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

@testable import StockPriceTracker
import XCTest

final class PriceFeedUseCaseTests: XCTestCase {

  private var sut: PriceFeedUseCase!
  private var mockSocket: MockStockSocketService!
  private var mockStore: MockStockPriceStore!

  override func setUp() {
    super.setUp()
    mockSocket = MockStockSocketService()
    mockStore  = MockStockPriceStore()
    sut = PriceFeedUseCase(
      socket: mockSocket,
      store: mockStore,
      updateInterval: 9999
    )
  }

  override func tearDown() {
    sut = nil
    mockSocket = nil
    mockStore  = nil
    super.tearDown()
  }

  func test_startFeed_callsSocketConnect() {
    sut.startFeed()

    XCTAssertEqual(mockSocket.connectCallCount, 1, "startFeed must call socket.connect() exactly once")
  }

  func test_stopFeed_callsSocketDisconnect() {
    sut.startFeed()
    sut.stopFeed()

    XCTAssertEqual(mockSocket.disconnectCallCount, 1, "stopFeed must call socket.disconnect() exactly once")
  }

  func test_startFeed_setsStoreConnectionStateToConnected() {
    sut.startFeed()

    XCTAssertEqual(mockStore.lastConnectionState, .connected)
  }

  func test_stopFeed_setsStoreConnectionStateToDisconnected() {
    sut.startFeed()
    sut.stopFeed()

    XCTAssertEqual(mockStore.lastConnectionState, .disconnected)
  }

  func test_validPriceUpdateJSON_isAppliedToStore() throws {
    let expected = PriceUpdate(ticker: "AAPL", price: 182.50, timestamp: Date(timeIntervalSince1970: 0))
    let json = try encodeToJSON(expected)

    sut.socketDidReceiveMessage(json)

    XCTAssertEqual(mockStore.appliedUpdates.count, 1)
    XCTAssertEqual(mockStore.lastAppliedUpdate?.ticker, "AAPL")
    XCTAssertEqual(mockStore.lastAppliedUpdate?.price ?? 0.0, 182.50, accuracy: 0.001)
  }

  func test_malformedJSON_doesNotApplyUpdateToStore() {
    sut.socketDidReceiveMessage("not-json-at-all")

    XCTAssertTrue(mockStore.appliedUpdates.isEmpty, "Malformed JSON must not produce a store update")
  }

  func test_emptyString_doesNotApplyUpdateToStore() {
    sut.socketDidReceiveMessage("")

    XCTAssertTrue(mockStore.appliedUpdates.isEmpty)
  }

  func test_jsonMissingRequiredFields_doesNotApplyUpdateToStore() {
    sut.socketDidReceiveMessage("{\"ticker\":\"TSLA\"}")

    XCTAssertTrue(mockStore.appliedUpdates.isEmpty, "Partial JSON without price must not produce a store update")
  }

  func test_parse_returnsCorrectUpdate_forValidJSON() throws {
    let expected = PriceUpdate(ticker: "NVDA", price: 875.0, timestamp: Date(timeIntervalSince1970: 1_000_000))
    let json = try encodeToJSON(expected)

    let result = sut.parse(message: json)

    XCTAssertNotNil(result)
    XCTAssertEqual(result?.ticker, "NVDA")
    XCTAssertEqual(result?.price ?? 0.0, 875.0, accuracy: 0.001)
  }

  func test_parse_returnsNil_forInvalidJSON() {
    XCTAssertNil(sut.parse(message: "garbage"))
  }

  func test_socketError_setsStoreToDisconnected() {
    sut.startFeed()
    sut.socketDidEncounterError(.connectionFailed("Timeout"))

    XCTAssertEqual(mockStore.lastConnectionState, .disconnected)
  }

  func test_useCase_registersItselfAsSocketListener() {
    XCTAssertTrue(mockSocket.listener === sut)
  }

  private func encodeToJSON(_ update: PriceUpdate) throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(update)
    return String(data: data, encoding: .utf8)!
  }
}
