//
//  NetworkPath.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 15.02.2024.
//

import CoreLocation
enum NetworkPath: RawRepresentable {
  static let apiKey_ = "key"

  static var apiKey: String? {
    return APIKeyStore.shared.apiKey
  }

  static let baseUrl = "https://api.openweathermap.org/data/2.5/"

  case weather(city: String)
  case weatherLanLat(location: CLLocation)
  case forecastLatLon(location: CLLocation)
  case forecast(city: String)
  case uvIndex(location: CLLocation)
  

  var rawValue: String {
    guard let apiKey = NetworkPath.apiKey else {
      return ""
    }

    switch self {
    case .weather(let city):
      return "weather?q=\(encoded(city))&appid=\(apiKey)&units=metric"
    case .weatherLanLat(location: let location):
      return "weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric"
    case .forecastLatLon(location: let location):
      return "forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&cnt=40"
    case .forecast(let city):
      return "forecast?q=\(encoded(city))&appid=\(apiKey)&units=metric&cnt=40"
    case .uvIndex(location: let location):
      return "uvi?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)"
    }
  }


  init?(rawValue: String) {
    // Gerekirse dönüşüm işlemleri burada yapılabilir
    return nil
  }

  func getPath() -> String {
    return self.rawValue
  }

  private func encoded(_ city: String) -> String {
    city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
  }
}
