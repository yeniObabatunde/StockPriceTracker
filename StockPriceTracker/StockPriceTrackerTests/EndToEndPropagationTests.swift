//
//  EndToEndPropagationTests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

@testable import StockPriceTracker
import XCTest

@MainActor
final class EndToEndPropagationTests: XCTestCase {

  private var mockSocket: MockStockSocketService!
  private var store: StockPriceStore!
  private var useCase: PriceFeedUseCase!
  private var listVM: StockListViewModel!

  override func setUp() {
    super.setUp()
    mockSocket = MockStockSocketService()
    store      = StockPriceStore()
    useCase    = PriceFeedUseCase(
      socket: mockSocket,
      store: store,
      updateInterval: 9999
    )
    listVM = StockListViewModel(store: store, priceFeed: useCase)
  }

  override func tearDown() {
    listVM    = nil
    useCase   = nil
    store     = nil
    mockSocket = nil
    super.tearDown()
  }

  func test_inboundSocketMessage_updatesSymbolInStore_andIsReflectedInVM() async throws {
    let json = try encodeBatch([PriceUpdate(ticker: "AAPL", price: 199.99, timestamp: .now)])
    mockSocket.simulateInboundMessage(json)
    await Task.yield()

    let aapl = store.symbol(for: "AAPL")
    XCTAssertEqual(aapl?.currentPrice ?? 0.0, 199.99, accuracy: 0.001)

    listVM.selectSort(.byPrice)
    XCTAssertEqual(listVM.sortedSymbols.first?.ticker, "AAPL")
  }

  func test_multipleRapidUpdates_allAppliedInOrder() async throws {
    let prices: [(String, Double)] = [("TSLA", 250.0), ("TSLA", 260.0), ("TSLA", 245.0)]
    for (ticker, price) in prices {
      mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: ticker, price: price, timestamp: .now)]))
    }
    await Task.yield()

    XCTAssertEqual(store.symbol(for: "TSLA")?.currentPrice ?? 0.0, 245.0, accuracy: 0.001)
  }

  func test_previousPrice_isUpdatedCorrectly_afterTwoUpdates() async throws {
    mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: "NVDA", price: 800.0, timestamp: .now)]))
    await Task.yield()
    mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: "NVDA", price: 850.0, timestamp: .now)]))
    await Task.yield()

    let nvda = store.symbol(for: "NVDA")
    XCTAssertEqual(nvda?.currentPrice  ?? 0.0, 850.0, accuracy: 0.001)
    XCTAssertEqual(nvda?.previousPrice ?? 0.0, 800.0, accuracy: 0.001)
  }

  func test_priceChangeDirection_isCorrect_afterUpdate() async throws {
    mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: "MSFT", price: 300.0, timestamp: .now)]))
    await Task.yield()
    mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: "MSFT", price: 350.0, timestamp: .now)]))
    await Task.yield()

    XCTAssertEqual(store.symbol(for: "MSFT")?.changeDirection, .up)
  }

  func test_unknownTicker_doesNotCorruptExistingSymbols() async throws {
    mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: "UNKNOWN_XYZ", price: 999.0, timestamp: .now)]))
    await Task.yield()

    XCTAssertEqual(store.symbols.count, StockSymbolSeed.all.count)
    XCTAssertNil(store.symbol(for: "UNKNOWN_XYZ"))
  }

  func test_socketConnect_propagatesToVM_connectionState() async {
    useCase.startFeed()
    await Task.yield()

    XCTAssertEqual(listVM.connectionState, .connected)
    XCTAssertTrue(listVM.isFeedActive)
  }

  func test_socketDisconnect_propagatesToVM_connectionState() async {
    useCase.startFeed()
    await Task.yield()
    useCase.stopFeed()
    await Task.yield()

    XCTAssertEqual(listVM.connectionState, .disconnected)
    XCTAssertFalse(listVM.isFeedActive)
  }

  func test_priceUpdate_isReflectedInDetailVM() async throws {
    let detailVM = StockDetailViewModel(ticker: "GOOG", store: store)
    mockSocket.simulateInboundMessage(try encodeBatch([PriceUpdate(ticker: "GOOG", price: 140.50, timestamp: .now)]))
    await Task.yield()

    XCTAssertEqual(detailVM.symbol?.currentPrice ?? 0.0, 140.50, accuracy: 0.001)
  }

 private func encodeBatch(_ updates: [PriceUpdate]) throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(updates)
    return String(data: data, encoding: .utf8)!
  }
}
