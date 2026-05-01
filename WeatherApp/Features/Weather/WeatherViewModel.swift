import Foundation
import CoreLocation

final class WeatherViewModel: ObservableObject {
    @Published var degree: Double? = nil
    @Published var cityName: String? = nil
    @Published var humidity: Int? = nil
    @Published var uvIndex: Double? = nil // UVIndex'in değeri Double olmalı
    private let manager = NetworkManager.networkManager

    func fetchWeather(city: String) async -> OpenWeatherMap? {
        let result = await manager.fetch(path: .weather(city: city), method: .get, type: OpenWeatherMap.self)
        
        DispatchQueue.main.async {
            self.degree = result?.main?.temp
            self.cityName = result?.name
            self.humidity = result?.main?.humidity
        }
        return result
    }

    func uvIndexFetch(location: CLLocation) async -> Double? {
        let result = await manager.fetch(path: NetworkPath.uvIndex(location: location), method: .get, type: UVIndex.self)
        
        DispatchQueue.main.async {
            self.uvIndex = result?.value
        }
        
        return result?.value
    }

    func kelvinToCelsius(kelvin: Double) -> Double {
        if kelvin < 100 {
            return kelvin
        }
        return kelvin - 273.15
    }
}
