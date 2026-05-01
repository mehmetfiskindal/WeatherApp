//
//  ForecastViewModel.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 8.09.2023.
//

import Foundation
@MainActor
final class ForecastViewModel: ObservableObject {
  @Published var forecastList: [Liste]? = [Liste]()
  private let manager = NetworkManager.networkManager

  func fetchForecast(city: String) async {
    let result = await manager.fetch(path: .forecast(city: city), method: .get, type: OpenWeatherMap.self)
    // We are on the main actor because the type is @MainActor, so it's safe to mutate published state.
    self.forecastList = result?.list
  }
  func kelvinToCelsius(kelvin: Double) -> Int {
    let celsius = Int(kelvin - 273.15)
    return celsius
  }
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust the date format as per your data
    return formatter
  }()
}
