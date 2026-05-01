//
//  WeatherTheme.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

enum WeatherCondition: String, CaseIterable, Identifiable {
  case sunny
  case rainy
  case cloudy
  case snowy
  case stormy
  case mist
  case night

  var id: String { rawValue }

  init(openWeatherMain: String?, isNight: Bool = false) {
    if isNight {
      self = .night
      return
    }

    switch openWeatherMain?.lowercased() {
    case "clear":
      self = .sunny
    case "rain", "drizzle":
      self = .rainy
    case "clouds":
      self = .cloudy
    case "snow":
      self = .snowy
    case "thunderstorm":
      self = .stormy
    case "mist", "smoke", "haze", "dust", "fog", "sand", "ash", "squall", "tornado":
      self = .mist
    default:
      self = .sunny
    }
  }
}

struct WeatherTheme {
  let condition: WeatherCondition
  let backgroundTop: Color
  let backgroundBottom: Color
  let accent: Color
  let surface: Color
  let textPrimary: Color
  let textSecondary: Color

  static let day = WeatherTheme(
    condition: .sunny,
    backgroundTop: WeatherColor.skyTop,
    backgroundBottom: WeatherColor.skyBottom,
    accent: WeatherColor.sunny,
    surface: WeatherColor.glassSurface,
    textPrimary: WeatherColor.textOnWeather,
    textSecondary: WeatherColor.textOnWeatherSecondary
  )

  static let night = WeatherTheme(
    condition: .night,
    backgroundTop: WeatherColor.nightTop,
    backgroundBottom: WeatherColor.nightBottom,
    accent: WeatherColor.weatherNight,
    surface: WeatherColor.glassSurface,
    textPrimary: WeatherColor.textOnWeather,
    textSecondary: WeatherColor.textOnWeatherSecondary
  )

  static func defaultTheme(for colorScheme: ColorScheme) -> WeatherTheme {
    colorScheme == .dark ? .night : .day
  }

  static func theme(for condition: WeatherCondition) -> WeatherTheme {
    switch condition {
    case .sunny:
      return .day
    case .rainy:
      return WeatherTheme(
        condition: .rainy,
        backgroundTop: WeatherColor.rainTop,
        backgroundBottom: WeatherColor.rainBottom,
        accent: WeatherColor.rainy,
        surface: WeatherColor.glassSurface,
        textPrimary: WeatherColor.textOnWeather,
        textSecondary: WeatherColor.textOnWeatherSecondary
      )
    case .cloudy:
      return WeatherTheme(
        condition: .cloudy,
        backgroundTop: WeatherColor.cloudTop,
        backgroundBottom: WeatherColor.cloudBottom,
        accent: WeatherColor.cloudy,
        surface: WeatherColor.glassSurface,
        textPrimary: WeatherColor.textOnWeather,
        textSecondary: WeatherColor.textOnWeatherSecondary
      )
    case .snowy:
      return WeatherTheme(
        condition: .snowy,
        backgroundTop: WeatherColor.snowTop,
        backgroundBottom: WeatherColor.snowBottom,
        accent: WeatherColor.snowy,
        surface: Color.white.opacity(0.58),
        textPrimary: WeatherColor.textPrimary,
        textSecondary: WeatherColor.textSecondary
      )
    case .stormy:
      return WeatherTheme(
        condition: .stormy,
        backgroundTop: WeatherColor.stormTop,
        backgroundBottom: WeatherColor.stormBottom,
        accent: WeatherColor.stormy,
        surface: WeatherColor.glassSurface,
        textPrimary: WeatherColor.textOnWeather,
        textSecondary: WeatherColor.textOnWeatherSecondary
      )
    case .mist:
      return WeatherTheme(
        condition: .mist,
        backgroundTop: WeatherColor.mistTop,
        backgroundBottom: WeatherColor.mistBottom,
        accent: WeatherColor.cloudy,
        surface: WeatherColor.glassSurface,
        textPrimary: WeatherColor.textOnWeather,
        textSecondary: WeatherColor.textOnWeatherSecondary
      )
    case .night:
      return .night
    }
  }
}
