//
//  WeatherInsightModels.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import Foundation

enum WeatherInsightSeverity: Equatable {
  case good
  case info
  case warning
  case danger

  var title: String {
    switch self {
    case .good:
      return "Uygun"
    case .info:
      return "Bilgi"
    case .warning:
      return "Dikkat"
    case .danger:
      return "Riskli"
    }
  }
}

struct WeatherInsightCard: Identifiable {
  let id: String
  let title: String
  let message: String
  let systemImage: String
  let severity: WeatherInsightSeverity
}

struct HourlyPlanItem: Identifiable {
  let id: String
  let timeRange: String
  let title: String
  let detail: String
  let systemImage: String
  let score: Int
}

struct WeatherInsightDashboard {
  let cityName: String
  let temperatureText: String
  let conditionText: String
  let summary: String
  let theme: WeatherTheme
  let cards: [WeatherInsightCard]
  let riskCards: [WeatherInsightCard]
  let hourlyPlan: [HourlyPlanItem]
}

struct WeatherInsightsCacheEntry: Codable {
  let cityName: String
  let current: OpenWeatherMap
  let forecast: OpenWeatherMap
  let uvIndex: Double?
  let savedAt: Date
}
