//
//  WeatherGlassCard.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct WeatherGlassCard<Content: View>: View {
  let theme: WeatherTheme
  let content: Content

  init(theme: WeatherTheme = .day, @ViewBuilder content: () -> Content) {
    self.theme = theme
    self.content = content()
  }

  var body: some View {
    content
      .padding(WeatherSpacing.md)
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WeatherRadius.lg, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: WeatherRadius.lg, style: .continuous)
          .stroke(WeatherColor.glassStroke, lineWidth: 1)
      }
      .weatherShadow(.soft)
  }
}
