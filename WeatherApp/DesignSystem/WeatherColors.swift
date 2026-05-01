//
//  WeatherColors.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

enum WeatherColor {
  static let primary = Color(hex: 0x4A90E2)
  static let secondary = Color(hex: 0x5C6BC0)
  static let background = Color(hex: 0xF4F8FC)
  static let surface = Color.white
  static let textPrimary = Color(hex: 0x101828)
  static let textSecondary = Color(hex: 0x667085)
  static let success = Color(hex: 0x34C759)
  static let warning = Color(hex: 0xFFB020)
  static let danger = Color(hex: 0xFF3B30)

  static let skyTop = Color(hex: 0x56CCF2)
  static let skyBottom = Color(hex: 0x2F80ED)
  static let nightTop = Color(hex: 0x141E30)
  static let nightBottom = Color(hex: 0x243B55)

  static let rainTop = Color(hex: 0x5C6BC0)
  static let rainBottom = Color(hex: 0x2F3A68)
  static let cloudTop = Color(hex: 0x90A4AE)
  static let cloudBottom = Color(hex: 0x607D8B)
  static let snowTop = Color(hex: 0xE1F5FE)
  static let snowBottom = Color(hex: 0x90CAF9)
  static let stormTop = Color(hex: 0x7E57C2)
  static let stormBottom = Color(hex: 0x263238)
  static let mistTop = Color(hex: 0xB0BEC5)
  static let mistBottom = Color(hex: 0x78909C)

  static let sunny = Color(hex: 0xFFD54F)
  static let rainy = Color(hex: 0x5C6BC0)
  static let snowy = Color(hex: 0xE1F5FE)
  static let stormy = Color(hex: 0x7E57C2)
  static let cloudy = Color(hex: 0x90A4AE)
  static let weatherNight = Color(hex: 0xB3C7FF)

  static let glassSurface = Color.white.opacity(0.16)
  static let glassStroke = Color.white.opacity(0.28)
  static let textOnWeather = Color.white
  static let textOnWeatherSecondary = Color(hex: 0xD0D7E2)
}

extension Color {
  init(hex: UInt, opacity: Double = 1) {
    let red = Double((hex >> 16) & 0xFF) / 255
    let green = Double((hex >> 8) & 0xFF) / 255
    let blue = Double(hex & 0xFF) / 255

    self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
