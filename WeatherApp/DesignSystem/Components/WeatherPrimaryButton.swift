//
//  WeatherPrimaryButton.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct WeatherPrimaryButton: View {
  let title: String
  let systemImage: String?
  let theme: WeatherTheme
  let action: () -> Void

  init(
    _ title: String,
    systemImage: String? = nil,
    theme: WeatherTheme = .day,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.systemImage = systemImage
    self.theme = theme
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: WeatherSpacing.xs) {
        if let systemImage {
          Image(systemName: systemImage)
        }
        Text(title)
      }
      .font(WeatherTypography.bodyStrong)
      .foregroundStyle(WeatherColor.textOnWeather)
      .frame(maxWidth: .infinity)
      .padding(.vertical, WeatherSpacing.md)
      .background(theme.accent, in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
    }
    .buttonStyle(.plain)
    .weatherShadow(.soft)
  }
}
