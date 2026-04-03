//
//  StockDetailViewSnapshotTests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import StockPriceTracker

final class StockDetailViewSnapshotTests: XCTestCase {

    private var store: MockStockPriceStore!

    override func setUp() {
        super.setUp()
        store = MockStockPriceStore()
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    func test_detailView_waitingForFirstPrice() {
        assertSnapshot(
            view: makeView(ticker: "AAPL"),
            name: "detail_AAPL_waiting_for_price",
            contentSizeMode: .screenDimensions
        )
    }

    func test_detailView_withLivePrice_andHistory() {
        store.applyBatchUpdate([PriceUpdate(ticker: "AAPL", price: 182.00, timestamp: .now)])
        store.applyBatchUpdate([PriceUpdate(ticker: "AAPL", price: 189.50, timestamp: .now)])

        assertSnapshot(
            view: makeView(ticker: "AAPL"),
            name: "detail_AAPL_live_price_with_history",
            contentSizeMode: .screenDimensions
        )
    }

    private func makeView(ticker: String) -> StockDetailView {
        StockDetailView(viewModel: StockDetailViewModel(ticker: ticker, store: store))
    }
}
