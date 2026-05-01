//
//  WeatherGradientBackground.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct WeatherGradientBackground: View {
  let theme: WeatherTheme

  var body: some View {
    LinearGradient(
      colors: [theme.backgroundTop, theme.backgroundBottom],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .ignoresSafeArea()
  }
}
