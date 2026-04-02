//
//  EndToEndPropagationTests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

@testable import StockPriceTracker
import XCTest

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

  func test_inboundSocketMessage_updatesSymbolInStore_andIsReflectedInVM() throws {
    let update = PriceUpdate(ticker: "AAPL", price: 199.99, timestamp: .now)
    let json   = try encode(update)

    mockSocket.simulateInboundMessage(json)

    let aapl = store.symbol(for: "AAPL")
    XCTAssertEqual(aapl?.currentPrice ?? 0.0, 199.99, accuracy: 0.001)

    listVM.selectSort(.byPrice)
    let topSymbol = listVM.sortedSymbols.first
    XCTAssertEqual(topSymbol?.ticker, "AAPL", "AAPL at $199.99 should sort to the top when it's the highest price")
  }

  func test_multipleRapidUpdates_allAppliedInOrder() throws {
    let updates: [(ticker: String, price: Double)] = [
      ("TSLA", 250.0),
      ("TSLA", 260.0),
      ("TSLA", 245.0)
    ]

    for (ticker, price) in updates {
      let json = try encode(PriceUpdate(ticker: ticker, price: price, timestamp: .now))
      mockSocket.simulateInboundMessage(json)
    }

    let tsla = store.symbol(for: "TSLA")
    XCTAssertEqual(tsla?.currentPrice ?? 0.0, 245.0, accuracy: 0.001, "Last update wins for the same ticker")
  }

  func test_previousPrice_isUpdatedCorrectly_afterTwoUpdates() throws {
    let first  = try encode(PriceUpdate(ticker: "NVDA", price: 800.0, timestamp: .now))
    let second = try encode(PriceUpdate(ticker: "NVDA", price: 850.0, timestamp: .now))

    mockSocket.simulateInboundMessage(first)
    mockSocket.simulateInboundMessage(second)

    let nvda = store.symbol(for: "NVDA")
    XCTAssertEqual(nvda?.currentPrice ?? 0.0,  850.0, accuracy: 0.001)
    XCTAssertEqual(nvda?.previousPrice ?? 0.0, 800.0, accuracy: 0.001)
  }

  func test_priceChangeDirection_isCorrect_afterUpdate() throws {
    let first  = try encode(PriceUpdate(ticker: "MSFT", price: 300.0, timestamp: .now))
    let second = try encode(PriceUpdate(ticker: "MSFT", price: 350.0, timestamp: .now))

    mockSocket.simulateInboundMessage(first)
    mockSocket.simulateInboundMessage(second)

    let msft = store.symbol(for: "MSFT")
    XCTAssertEqual(msft?.changeDirection, .up)
  }

  func test_unknownTicker_doesNotCorruptExistingSymbols() throws {
    let json = try encode(PriceUpdate(ticker: "UNKNOWN_XYZ", price: 999.0, timestamp: .now))

    mockSocket.simulateInboundMessage(json)

    XCTAssertEqual(store.symbols.count, StockSymbolSeed.all.count, "Unknown ticker must not add or remove symbols")
    XCTAssertNil(store.symbol(for: "UNKNOWN_XYZ"))
  }

  func test_socketConnect_propagatesToVM_connectionState() {
    useCase.startFeed()

    XCTAssertEqual(listVM.connectionState, .connected)
    XCTAssertTrue(listVM.isFeedActive)
  }

  func test_socketDisconnect_propagatesToVM_connectionState() {
    useCase.startFeed()
    useCase.stopFeed()

    XCTAssertEqual(listVM.connectionState, .disconnected)
    XCTAssertFalse(listVM.isFeedActive)
  }

  func test_priceUpdate_isReflectedInDetailVM() throws {
    let detailVM = StockDetailViewModel(ticker: "GOOG", store: store)
    let json = try encode(PriceUpdate(ticker: "GOOG", price: 140.50, timestamp: .now))

    mockSocket.simulateInboundMessage(json)

    XCTAssertEqual(detailVM.symbol?.currentPrice ?? 0.0, 140.50, accuracy: 0.001,
                   "Detail VM must reflect updates applied via the socket without any additional wiring")
  }

  private func encode(_ update: PriceUpdate) throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(update)
    return String(data: data, encoding: .utf8)!
  }
}
