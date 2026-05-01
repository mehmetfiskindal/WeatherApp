//
//  WeatherShadows.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct WeatherShadow {
  let color: Color
  let radius: CGFloat
  let x: CGFloat
  let y: CGFloat

  static let soft = WeatherShadow(
    color: Color.black.opacity(0.14),
    radius: 18,
    x: 0,
    y: 10
  )

  static let lifted = WeatherShadow(
    color: Color.black.opacity(0.22),
    radius: 28,
    x: 0,
    y: 18
  )
}

extension View {
  func weatherShadow(_ shadow: WeatherShadow = .soft) -> some View {
    self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
  }
}
