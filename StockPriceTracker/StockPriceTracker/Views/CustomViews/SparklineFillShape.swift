//
//  SparklineFillShape.swift
//  StockPriceTracker
//
//  Created by Sharon Omoyeni Babatunde on 01/04/2026.
//

import SwiftUI

struct SparklineFillShape: Shape {
   var history: [Double]
   var min: Double
   var max: Double

   func path(in rect: CGRect) -> Path {
       guard history.count > 1 else { return Path() }
       var path = Path()
       let range = max - min
       let step = rect.width / CGFloat(history.count - 1)

       path.move(to: CGPoint(x: 0, y: rect.height))

       for (i, price) in history.enumerated() {
           let x = CGFloat(i) * step
           let normalised = range > 0 ? (price - min) / range : 0.5
           let y = rect.height * (1 - normalised)
           path.addLine(to: CGPoint(x: x, y: y))
       }
       path.addLine(to: CGPoint(x: rect.width, y: rect.height))
       path.closeSubpath()
       return path
   }
}
