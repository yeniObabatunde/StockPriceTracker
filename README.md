# StockPriceTracker

A production-grade iOS app that streams real-time stock price updates for 25 symbols over WebSocket, displaying live prices across a scrollable list and a per-symbol detail screen.

## Demo

<div align="leading">
<img src="https://github.com/user-attachments/assets/e79e1d64-7c25-4890-b1e9-952801a327b4" alt="gif" width="200">
</div>

### Screenshots

<div style="display: flex; justify-content: space-between;">
<img src="https://github.com/user-attachments/assets/a286e903-7833-45e5-886b-ad62d88048a2" width="200" alt="Stock List (Price)">
<img src="https://github.com/user-attachments/assets/a286e903-7833-45e5-886b-ad62d88048a2" width="200" alt="Stock List (Change)">
<img src="https://github.com/user-attachments/assets/90ab2c9c-25fe-4ee8-9748-79a7b6a8d782" width="200" alt="Stock Detail">
</div>
---

## Features

- Live price streaming via WebSocket
- 25 symbols with random price simulation on each tick
- Sort by current price or by price change
- Per-symbol detail screen with sparkline chart, stats grid, and description
- Connection status indicator with start/stop feed toggle
- Exponential backoff reconnection on unexpected disconnect
- Batch price updates for efficient live update
- Full unit test suite with XCTest
- Robust Snapshot testing for visual regression
- Protocol-oriented architecture
---

## Technical Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI | SwiftUI (100%) |
| State | `@Observable` macro |
| Networking | `URLSessionWebSocketTask` |
| Architecture | MVVM + Use Case |
| Unit Testing | XCTest |
| Snapshot Testing | PointFree swift-snapshot-testing 1.18.9 |
| Dependency Management | Swift Package Manager |

---

## Architecture

The app is structured around three distinct layers of responsibility.

**Service layer** — `LiveStockSocketService` owns the raw WebSocket connection. It handles connect/disconnect, ping keepalives, message receipt, and exponential backoff reconnection. It communicates upward exclusively through the `SocketEventListening` protocol, keeping the transport completely decoupled from business logic.

**Use case layer** — `PriceFeedUseCase` sits between the socket and the store. On connect it starts a `Timer` that encodes a full batch of 25 simulated price ticks and sends them down the socket. On receipt it decodes the echoed batch and writes it to the store in a single `applyBatchUpdate` call. It also implements `SocketEventListening` and forwards connection state changes to the store.

**Store layer** — `StockPriceStore` is an `@Observable` value store. It holds the array of `StockSymbol` structs, updates `previousPrice` and `currentPrice` on each batch write, and maintains a rolling 40-point price history per ticker for the sparkline.

```
StockPriceTrackerApp
└── StockPriceTrackerView
    └── StockListView  ──(NavigationLink)──▶  StockDetailView
            │                                        │
    StockListViewModel                      StockDetailViewModel
            │                                        │
            └──────────── StockPriceStore ───────────┘
                                │
                        PriceFeedUseCase
                                │
                    LiveStockSocketService
                                │
                    wss://ws.postman-echo.com/raw
```

---

## Project Structure

```
StockPriceTracker/
├── App/
│   ├── StockPriceTrackerApp.swift
│   └── StockPriceTrackerView.swift
├── Model/
│   ├── StockSymbol.swift
│   ├── PriceUpdate.swift
│   └── StockSymbolSeed.swift
├── Service/
│   ├── Websocket/
│   │   └── LiveStockSocketService.swift
│   ├── PriceFeedUseCase.swift
│   ├── SocketProtocols.swift
│   ├── StockPriceStore.swift
│   └── StoreProtocols.swift
├── ViewModel/
│   ├── StockListViewModel.swift
│   └── StockDetailViewModel.swift
├── Views/
│   ├── HomePage/
│   │   └── StockListView.swift
│   ├── DetailsPage/
│   │   └── StockDetailView.swift
│   └── CustomViews/
└── Helpers/

StockPriceTrackerTests/
├── Mocks/
│   ├── MockStockSocketService.swift
│   └── MockStockPriceStore.swift
├── UnitTests/
│   ├── PriceFeedUseCaseTests.swift
│   └── EndToEndPropagationTests.swift
└── SnapshotTests/
    ├── StockListViewSnapshotTests.swift
    └── StockDetailViewSnapshotTests.swift
```

---

## Testing Strategy

The test suite is split into three layers, each with a distinct job.

**Unit tests (`PriceFeedUseCaseTests`)** test the use case in complete isolation using `MockStockSocketService` and `MockStockPriceStore`. They verify that `startFeed` calls `connect` exactly once, that valid batch JSON is decoded and forwarded to the store, that malformed or partial JSON produces no store write, and that socket errors propagate as disconnected state.

**Integration tests (`EndToEndPropagationTests`)** wire the real `StockPriceStore` to the real `PriceFeedUseCase` with only the socket mocked. They verify the full propagation chain — a message arriving at the socket eventually updates the store and is reflected in both `StockListViewModel` and `StockDetailViewModel` without any additional wiring.

**Snapshot tests** instantiate views directly with controlled mock data and compare rendered output against reference images on disk. The list is tested in its disconnected/alphabetical state and its active/price-sorted state. The detail is tested in its waiting-for-first-price state (placeholder chart) and its fully populated state (hero price, sparkline, stats grid).

All test classes are marked `@MainActor` to match the `@MainActor` isolation on `SocketEventListening`, and async tests use `await Task.yield()` to let `Task`-dispatched callbacks land before asserting.

---

## Running the App
```bash
git clone https://github.com/yeniObabatunde/StockPriceTracker.git
cd StockPriceTracker
open StockPriceTracker.xcodeproj
```

Select a simulator running iOS 18+ and press `Cmd+R`.

## Running Tests

Press `Cmd+U` to run the full suite.

To record new snapshot references after a UI change, set `isRecording = true` in `SnapshotTestingConfig`, run the snapshot tests once, then set it back to `false` and commit the new reference images.

---

## Requirements

- iOS 18.0+
- Xcode 15.0+
- Swift 5.9+

---

## Author

Sharon Omoyeni Babatunde
