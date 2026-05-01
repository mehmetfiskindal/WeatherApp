//
//  WeatherMetricTile.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct WeatherMetricTile: View {
  let title: String
  let value: String
  let systemImage: String
  let theme: WeatherTheme

  var body: some View {
    HStack(spacing: WeatherSpacing.sm) {
      Image(systemName: systemImage)
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(theme.accent)
        .frame(width: 36, height: 36)
        .background(Color.white.opacity(0.18), in: Circle())

      VStack(alignment: .leading, spacing: WeatherSpacing.xxs) {
        Text(title)
          .font(WeatherTypography.caption)
          .foregroundStyle(theme.textSecondary)

        Text(value)
          .font(WeatherTypography.metricValue)
          .foregroundStyle(theme.textPrimary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }

      Spacer(minLength: 0)
    }
    .padding(WeatherSpacing.md)
    .background(theme.surface, in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
  }
}
