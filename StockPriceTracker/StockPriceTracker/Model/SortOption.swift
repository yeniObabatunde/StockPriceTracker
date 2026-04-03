//
//  SortOption.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import Foundation

public enum SortOption: String, CaseIterable, Equatable, Sendable {
    case byPrice = "Price"
    case byPriceChange = "Change"
}
