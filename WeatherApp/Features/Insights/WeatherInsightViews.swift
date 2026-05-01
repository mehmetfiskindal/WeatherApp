//
//  WeatherInsightViews.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct SmartWeatherHeroView: View {
  let dashboard: WeatherInsightDashboard
  let isCached: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: WeatherSpacing.md) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: WeatherSpacing.xs) {
          Text(dashboard.cityName)
            .font(WeatherTypography.heroTitle)
            .foregroundStyle(dashboard.theme.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)

          Text(dashboard.conditionText)
            .font(WeatherTypography.subtitle)
            .foregroundStyle(dashboard.theme.textSecondary)
        }

        Spacer()

        Text(dashboard.temperatureText)
          .font(WeatherTypography.heroTemperature)
          .foregroundStyle(dashboard.theme.textPrimary)
          .minimumScaleFactor(0.7)
      }

      Text(dashboard.summary)
        .font(WeatherTypography.bodyStrong)
        .foregroundStyle(dashboard.theme.textPrimary)
        .fixedSize(horizontal: false, vertical: true)

      if isCached {
        Label("Cache verisi gösteriliyor, arka planda güncellenebilir.", systemImage: "clock.arrow.circlepath")
          .font(WeatherTypography.caption)
          .foregroundStyle(dashboard.theme.textSecondary)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(dashboard.cityName), \(dashboard.temperatureText), \(dashboard.summary)")
  }
}

struct WeatherInsightCardView: View {
  let card: WeatherInsightCard
  let theme: WeatherTheme

  var body: some View {
    HStack(alignment: .top, spacing: WeatherSpacing.sm) {
      Image(systemName: card.systemImage)
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(tint)
        .frame(width: 40, height: 40)
        .background(tint.opacity(0.18), in: Circle())

      VStack(alignment: .leading, spacing: WeatherSpacing.xs) {
        ViewThatFits(in: .horizontal) {
          HStack(spacing: WeatherSpacing.xs) {
            titleLabel
            severityBadge
          }

          VStack(alignment: .leading, spacing: WeatherSpacing.xxs) {
            titleLabel
            severityBadge
          }
        }

        Text(card.message)
          .font(WeatherTypography.body)
          .foregroundStyle(theme.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .padding(WeatherSpacing.md)
    .background(theme.surface, in: RoundedRectangle(cornerRadius: WeatherRadius.lg, style: .continuous))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(card.title). \(card.message)")
  }

  private var tint: Color {
    switch card.severity {
    case .good:
      return WeatherColor.success
    case .info:
      return theme.accent
    case .warning:
      return WeatherColor.warning
    case .danger:
      return WeatherColor.danger
    }
  }

  private var titleLabel: some View {
    Text(card.title)
      .font(WeatherTypography.bodyStrong)
      .foregroundStyle(theme.textPrimary)
  }

  private var severityBadge: some View {
    Text(card.severity.title)
      .font(WeatherTypography.caption)
      .padding(.horizontal, WeatherSpacing.xs)
      .padding(.vertical, WeatherSpacing.xxs)
      .background(tint.opacity(0.18), in: Capsule())
      .foregroundStyle(tint)
  }
}

struct HourlyPlanRow: View {
  let item: HourlyPlanItem
  let theme: WeatherTheme

  var body: some View {
    HStack(spacing: WeatherSpacing.sm) {
      VStack(alignment: .leading, spacing: WeatherSpacing.xxs) {
        Text(item.timeRange)
          .font(WeatherTypography.caption)
          .foregroundStyle(theme.textSecondary)

        Text(item.title)
          .font(WeatherTypography.bodyStrong)
          .foregroundStyle(theme.textPrimary)

        Text(item.detail)
          .font(WeatherTypography.caption)
          .foregroundStyle(theme.textSecondary)
      }

      Spacer()

      Label("\(item.score)", systemImage: item.systemImage)
        .font(WeatherTypography.bodyStrong)
        .foregroundStyle(theme.accent)
        .accessibilityLabel("Uygunluk skoru \(item.score)")
    }
    .padding(WeatherSpacing.md)
    .background(theme.surface, in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
    .accessibilityElement(children: .combine)
  }
}
