//
//  StockListViewSnapshotTests.swift
//  StockPriceTrackerTests
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import StockPriceTracker

final class StockListViewSnapshotTests: XCTestCase {

    private var store: MockStockPriceStore!
    private var viewModel: StockListViewModel!

    override func setUp() {
        super.setUp()
        store     = MockStockPriceStore()
        viewModel = StockListViewModel(store: store, priceFeed: MockPriceFeedManaging())
    }

    override func tearDown() {
        viewModel = nil
        store     = nil
        super.tearDown()
    }

    func test_listView_initialState_disconnectedFeed() {
        assertSnapshot(view: makeView(),
                       name: "list_disconnected_alphabetical",
                       contentSizeMode: .screenDimensions)
    }

    func test_listView_activeFeed_sortedByPrice() {
        viewModel.selectSort(.byPrice)
        store.applyBatchUpdate([
            PriceUpdate(ticker: "AAPL", price: 199.99, timestamp: .now),
            PriceUpdate(ticker: "NVDA", price: 875.00, timestamp: .now),
            PriceUpdate(ticker: "TSLA", price:  52.30, timestamp: .now)
        ])

        assertSnapshot(view: makeView(),
                       name: "list_active_sorted_by_price",
                       contentSizeMode: .screenDimensions)
    }

    private func makeView() -> StockListView {
        StockListView(
            viewModel: viewModel,
            detailVMFactory: { StockDetailViewModel(ticker: $0, store: self.store) }
        )
    }
}
