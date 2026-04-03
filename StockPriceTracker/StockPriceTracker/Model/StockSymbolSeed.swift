//
//  StockSymbolSeed.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import Foundation

public enum StockSymbolSeed {
  public static let all: [StockSymbol] = [
    .init(ticker: "AAPL",  companyName: "Apple Inc.",               description: "Designs and manufactures consumer electronics, software and online services."),
    .init(ticker: "GOOG",  companyName: "Alphabet Inc.",            description: "Parent company of Google, operating in search, cloud, and advertising."),
    .init(ticker: "TSLA",  companyName: "Tesla Inc.",               description: "Electric vehicle and clean energy company."),
    .init(ticker: "AMZN",  companyName: "Amazon.com Inc.",          description: "E-commerce, cloud computing, digital streaming and AI."),
    .init(ticker: "MSFT",  companyName: "Microsoft Corp.",          description: "Software, cloud services, and productivity tools."),
    .init(ticker: "NVDA",  companyName: "NVIDIA Corp.",             description: "Designs GPUs for gaming, data centres, and AI workloads."),
    .init(ticker: "META",  companyName: "Meta Platforms Inc.",      description: "Social media and virtual reality products."),
    .init(ticker: "NFLX",  companyName: "Netflix Inc.",             description: "Subscription streaming service for film and television."),
    .init(ticker: "BRKB",  companyName: "Berkshire Hathaway B",     description: "Diversified holding company led by Warren Buffett."),
    .init(ticker: "JPM",   companyName: "JPMorgan Chase & Co.",     description: "Global financial services and investment banking."),
    .init(ticker: "V",     companyName: "Visa Inc.",                description: "Worldwide digital payments network."),
    .init(ticker: "UNH",   companyName: "UnitedHealth Group",       description: "Diversified health care and insurance services."),
    .init(ticker: "JNJ",   companyName: "Johnson & Johnson",        description: "Pharmaceutical, medical devices, and consumer health."),
    .init(ticker: "WMT",   companyName: "Walmart Inc.",             description: "Multinational retail corporation."),
    .init(ticker: "MA",    companyName: "Mastercard Inc.",          description: "Global payments technology company."),
    .init(ticker: "PG",    companyName: "Procter & Gamble Co.",     description: "Consumer goods covering hygiene, health, and grooming."),
    .init(ticker: "HD",    companyName: "The Home Depot Inc.",      description: "Home improvement retail chain."),
    .init(ticker: "DIS",   companyName: "The Walt Disney Co.",      description: "Entertainment, theme parks, and streaming."),
    .init(ticker: "PYPL",  companyName: "PayPal Holdings Inc.",     description: "Online payments system and digital wallet."),
    .init(ticker: "ADBE",  companyName: "Adobe Inc.",               description: "Software for creative professionals and digital marketing."),
    .init(ticker: "CRM",   companyName: "Salesforce Inc.",          description: "Cloud-based customer relationship management platform."),
    .init(ticker: "INTC",  companyName: "Intel Corp.",              description: "Semiconductor chips for computing and data centres."),
    .init(ticker: "AMD",   companyName: "Advanced Micro Devices",   description: "CPUs and GPUs for PCs, servers, and gaming consoles."),
    .init(ticker: "QCOM",  companyName: "Qualcomm Inc.",            description: "Wireless technology and semiconductor products."),
    .init(ticker: "SPOT",  companyName: "Spotify Technology SA",    description: "Audio streaming and media services platform.")
  ]
}
