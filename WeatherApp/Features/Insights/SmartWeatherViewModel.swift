//
//  SmartWeatherViewModel.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import Alamofire
import CoreLocation
import Foundation

@MainActor
final class SmartWeatherViewModel: ObservableObject {
  enum ViewState {
    case empty
    case loading
    case loaded(WeatherInsightDashboard, isCached: Bool)
    case error(String, cached: WeatherInsightDashboard?)
  }

  @Published var state: ViewState = .empty
  @Published var searchText: String = ""

  private let manager = NetworkManager.networkManager
  private let cache = WeatherInsightsCache.shared

  var currentDashboard: WeatherInsightDashboard? {
    switch state {
    case .loaded(let dashboard, _):
      return dashboard
    case .error(_, let cached):
      return cached
    case .empty, .loading:
      return nil
    }
  }

  var stateID: String {
    switch state {
    case .empty:
      return "empty"
    case .loading:
      return "loading"
    case .loaded(let dashboard, let isCached):
      return "loaded-\(dashboard.cityName)-\(isCached)"
    case .error(let message, let cached):
      return "error-\(message)-\(cached?.cityName ?? "none")"
    }
  }

  func load(city: String) async {
    let cityName = city.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cityName.isEmpty else {
      state = .empty
      return
    }

    if let cachedEntry = cache.load(cityName: cityName) {
      state = .loaded(makeDashboard(from: cachedEntry), isCached: true)
    } else {
      state = .loading
    }

    let currentResult: Result<OpenWeatherMap, WeatherAPIError> = await manager.fetchResult(path: .weather(city: cityName), method: .get, type: OpenWeatherMap.self)
    let forecastResult: Result<OpenWeatherMap, WeatherAPIError> = await manager.fetchResult(path: .forecast(city: cityName), method: .get, type: OpenWeatherMap.self)

    switch (currentResult, forecastResult) {
    case (.success(let current), .success(let forecast)):
      let uvIndex = await fetchUVIndex(for: current)
      let entry = WeatherInsightsCacheEntry(
        cityName: current.name ?? cityName,
        current: current,
        forecast: forecast,
        uvIndex: uvIndex,
        savedAt: Date()
      )
      cache.save(entry)
      state = .loaded(makeDashboard(from: entry), isCached: false)
    case (.failure(let error), _), (_, .failure(let error)):
      let cachedDashboard = currentDashboard
      state = .error(error.localizedDescription, cached: cachedDashboard)
    }
  }

  func load(location: CLLocation) async {
    state = .loading

    let currentResult: Result<OpenWeatherMap, WeatherAPIError> = await manager.fetchResult(path: .weatherLanLat(location: location), method: .get, type: OpenWeatherMap.self)
    let forecastResult: Result<OpenWeatherMap, WeatherAPIError> = await manager.fetchResult(path: .forecastLatLon(location: location), method: .get, type: OpenWeatherMap.self)

    switch (currentResult, forecastResult) {
    case (.success(let current), .success(let forecast)):
      let cityName = current.name ?? "Konumum"
      let uvIndex = await fetchUVIndex(for: location)
      let entry = WeatherInsightsCacheEntry(
        cityName: cityName,
        current: current,
        forecast: forecast,
        uvIndex: uvIndex,
        savedAt: Date()
      )
      searchText = cityName
      cache.save(entry)
      state = .loaded(makeDashboard(from: entry), isCached: false)
    case (.failure(let error), _), (_, .failure(let error)):
      state = .error(error.localizedDescription, cached: currentDashboard)
    }
  }

  private func fetchUVIndex(for current: OpenWeatherMap) async -> Double? {
    guard let lat = current.coord?.lat, let lon = current.coord?.lon else { return nil }
    return await fetchUVIndex(for: CLLocation(latitude: lat, longitude: lon))
  }

  private func fetchUVIndex(for location: CLLocation) async -> Double? {
    let result: Result<UVIndex, WeatherAPIError> = await manager.fetchResult(path: .uvIndex(location: location), method: .get, type: UVIndex.self)
    if case .success(let uvIndex) = result {
      return uvIndex.value
    }
    return nil
  }

  private func makeDashboard(from entry: WeatherInsightsCacheEntry) -> WeatherInsightDashboard {
    WeatherInsightsEngine.makeDashboard(
      current: entry.current,
      forecast: entry.forecast,
      uvIndex: entry.uvIndex
    )
  }
}
