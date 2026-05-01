//
//  WeatherInsightsCache.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import Foundation

final class WeatherInsightsCache {
  static let shared = WeatherInsightsCache()

  private let defaults = UserDefaults.standard
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let ttl: TimeInterval = 30 * 60

  private init() {}

  func save(_ entry: WeatherInsightsCacheEntry) {
    guard let data = try? encoder.encode(entry) else { return }
    defaults.set(data, forKey: key(for: entry.cityName))
  }

  func load(cityName: String) -> WeatherInsightsCacheEntry? {
    guard let data = defaults.data(forKey: key(for: cityName)),
      let entry = try? decoder.decode(WeatherInsightsCacheEntry.self, from: data),
      Date().timeIntervalSince(entry.savedAt) <= ttl else {
      return nil
    }

    return entry
  }

  private func key(for cityName: String) -> String {
    "weather.insights.\(cityName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())"
  }
}
