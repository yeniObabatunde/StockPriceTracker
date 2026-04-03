//
//  PriceFeedUseCaseTests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

@testable import StockPriceTracker
import XCTest

@MainActor
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
    XCTAssertEqual(mockSocket.connectCallCount, 1)
  }

  func test_stopFeed_callsSocketDisconnect() {
    sut.startFeed()
    sut.stopFeed()
    XCTAssertEqual(mockSocket.disconnectCallCount, 1)
  }

  func test_startFeed_setsStoreConnectionStateToConnected() async {
    sut.startFeed()
    await Task.yield()
    XCTAssertEqual(mockStore.lastConnectionState, .connected)
  }

  func test_stopFeed_setsStoreConnectionStateToDisconnected() async {
    sut.startFeed()
    sut.stopFeed()
    await Task.yield()
    XCTAssertEqual(mockStore.lastConnectionState, .disconnected)
  }

  func test_validPriceUpdateJSON_isAppliedToStore() throws {
    let update = PriceUpdate(ticker: "AAPL", price: 182.50, timestamp: Date(timeIntervalSince1970: 0))
    let json   = try encodeBatch([update])

    sut.socketDidReceiveMessage(json)

    XCTAssertEqual(mockStore.batchUpdates.count, 1)
    XCTAssertEqual(mockStore.lastAppliedUpdate?.ticker, "AAPL")
    XCTAssertEqual(mockStore.lastAppliedUpdate?.price ?? 0.0, 182.50, accuracy: 0.001)
  }

  func test_multiplePricesInOneBatch_allAppliedToStore() throws {
    let updates = [
      PriceUpdate(ticker: "AAPL", price: 182.50, timestamp: .now),
      PriceUpdate(ticker: "GOOG", price: 175.00, timestamp: .now)
    ]
    let json = try encodeBatch(updates)

    sut.socketDidReceiveMessage(json)

    XCTAssertEqual(mockStore.batchUpdates.count, 1)
    XCTAssertEqual(mockStore.lastBatch?.count, 2)
  }

  func test_malformedJSON_doesNotApplyUpdateToStore() {
    sut.socketDidReceiveMessage("not-json-at-all")
    XCTAssertTrue(mockStore.batchUpdates.isEmpty)
  }

  func test_emptyString_doesNotApplyUpdateToStore() {
    sut.socketDidReceiveMessage("")
    XCTAssertTrue(mockStore.batchUpdates.isEmpty)
  }

  func test_jsonMissingRequiredFields_doesNotApplyUpdateToStore() {
    sut.socketDidReceiveMessage("[{\"ticker\":\"TSLA\"}]")
    XCTAssertTrue(mockStore.batchUpdates.isEmpty)
  }

  func test_parse_returnsCorrectUpdates_forValidBatchJSON() throws {
    let expected = PriceUpdate(ticker: "NVDA", price: 875.0, timestamp: Date(timeIntervalSince1970: 1_000_000))
    let json     = try encodeBatch([expected])

    let result = sut.parse(message: json)

    XCTAssertEqual(result?.count, 1)
    let update = try XCTUnwrap(result?.first)
    XCTAssertEqual(update.ticker, "NVDA")
    XCTAssertEqual(update.price, 875.0, accuracy: 0.001)
  }

  func test_parse_returnsNil_forInvalidJSON() {
    XCTAssertNil(sut.parse(message: "garbage"))
  }

  func test_socketError_setsStoreToDisconnected() async {
    sut.startFeed()
    await Task.yield()
    sut.socketDidEncounterError(.connectionFailed("Timeout"))
    XCTAssertEqual(mockStore.lastConnectionState, .disconnected)
  }

  func test_useCase_registersItselfAsSocketListener() {
    XCTAssertTrue(mockSocket.listener === sut)
  }

  private func encodeBatch(_ updates: [PriceUpdate]) throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(updates)
    return String(data: data, encoding: .utf8)!
  }
}
