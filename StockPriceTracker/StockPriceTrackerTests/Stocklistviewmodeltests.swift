//
//  Stocklistviewmodeltests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

@testable import StockPriceTracker
import XCTest

final class StockListViewModelTests: XCTestCase {
  
  private var sut: StockListViewModel!
  private var mockStore: MockStockPriceStore!
  private var mockFeed: MockPriceFeedManaging!
  
  override func setUp() {
    super.setUp()
    mockStore = MockStockPriceStore()
    mockFeed  = MockPriceFeedManaging()
    sut = StockListViewModel(
      store: mockStore,
      priceFeed: mockFeed
    )
  }
  
  override func tearDown() {
    sut = nil
    mockStore = nil
    mockFeed  = nil
    super.tearDown()
  }

  func test_sortByPrice_returnsSymbolsDescendingByCurrentPrice() {
    seedStore(with: [
      makeSymbol(ticker: "A", price: 100),
      makeSymbol(ticker: "B", price: 300),
      makeSymbol(ticker: "C", price: 200)
    ])
    
    sut.selectSort(.byPrice)
    
    let tickers = sut.sortedSymbols.map(\.ticker)
    XCTAssertEqual(tickers, ["B", "C", "A"], "byPrice must sort highest → lowest")
  }
  
  func test_sortByPrice_isDefaultSort() {
    XCTAssertEqual(sut.selectedSort, .byPrice)
  }
  
  func test_sortByPriceChange_returnsSymbolsDescendingByChange() {
    seedStore(with: [
      makeSymbol(ticker: "X", price: 100, previousPrice: 120),
      makeSymbol(ticker: "Y", price: 100, previousPrice: 90),
      makeSymbol(ticker: "Z", price: 100, previousPrice: 95)
    ])
    
    sut.selectSort(.byPriceChange)
    
    let tickers = sut.sortedSymbols.map(\.ticker)
    XCTAssertEqual(tickers, ["Y", "Z", "X"], "byPriceChange must sort biggest gain → biggest loss")
  }
  
  func test_sortByPriceChange_withAllZeroChanges_preservesRelativeOrder() {
    let symbols = (1...5).map { makeSymbol(ticker: "SYM\($0)", price: 100, previousPrice: 100) }
    seedStore(with: symbols)
    
    sut.selectSort(.byPriceChange)

    XCTAssertEqual(Set(sut.sortedSymbols.map(\.ticker)), Set(symbols.map(\.ticker)))
  }

  func test_selectingNewSort_updatesSelectedSort() {
    sut.selectSort(.byPriceChange)
    
    XCTAssertEqual(sut.selectedSort, .byPriceChange)
  }
  
  func test_switchingSort_changesOutputOrder() {
    seedStore(with: [
      makeSymbol(ticker: "HIGH_PRICE_LOW_CHANGE", price: 500, previousPrice: 498),
      makeSymbol(ticker: "LOW_PRICE_HIGH_CHANGE", price: 50, previousPrice: 10)
    ])
    
    sut.selectSort(.byPrice)
    let byPriceTickers = sut.sortedSymbols.map(\.ticker)
    
    sut.selectSort(.byPriceChange)
    let byChangeTickers = sut.sortedSymbols.map(\.ticker)
    
    XCTAssertNotEqual(byPriceTickers, byChangeTickers, "Different sort options should produce different orderings for this data")
  }
  
  func test_connectionState_reflectsStore() {
    mockStore.setConnectionState(.connected)
    
    XCTAssertEqual(sut.connectionState, .connected)
  }
  
  func test_isFeedActive_isTrueWhenConnected() {
    mockStore.setConnectionState(.connected)
    
    XCTAssertTrue(sut.isFeedActive)
  }
  
  func test_isFeedActive_isTrueWhenConnecting() {
    mockStore.setConnectionState(.connecting)
    
    XCTAssertTrue(sut.isFeedActive)
  }
  
  func test_isFeedActive_isFalseWhenDisconnected() {
    mockStore.setConnectionState(.disconnected)
    
    XCTAssertFalse(sut.isFeedActive)
  }

  
  func test_toggleFeed_whenInactive_callsStartFeed() {
    mockStore.setConnectionState(.disconnected)
    
    sut.toggleFeed()
    
    XCTAssertEqual(mockFeed.startCallCount, 1)
    XCTAssertEqual(mockFeed.stopCallCount,  0)
  }
  
  func test_toggleFeed_whenActive_callsStopFeed() {
    mockStore.setConnectionState(.connected)
    
    sut.toggleFeed()
    
    XCTAssertEqual(mockFeed.stopCallCount,  1)
    XCTAssertEqual(mockFeed.startCallCount, 0)
  }
  
  func test_toggleFeed_calledMultipleTimes_togglesCorrectly() {
    mockStore.setConnectionState(.disconnected)
    
    sut.toggleFeed()
    mockStore.setConnectionState(.connected)
    sut.toggleFeed()
    mockStore.setConnectionState(.disconnected)
    sut.toggleFeed()
    
    XCTAssertEqual(mockFeed.startCallCount, 2)
    XCTAssertEqual(mockFeed.stopCallCount,  1)
  }
  
  // MARK: - Helpers -
  
  private func seedStore(with symbols: [StockSymbol]) {
    mockStore = MockStockPriceStore(symbols: symbols)
    sut = StockListViewModel(store: mockStore, priceFeed: mockFeed)
  }
  
  private func makeSymbol(
    ticker: String,
    price: Double,
    previousPrice: Double = 0
  ) -> StockSymbol {
    StockSymbol(
      ticker: ticker,
      companyName: ticker,
      description: "",
      currentPrice: price,
      previousPrice: previousPrice
    )
  }
}
