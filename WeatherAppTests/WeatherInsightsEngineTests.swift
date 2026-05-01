//
//  WeatherInsightsEngineTests.swift
//  WeatherAppTests
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import XCTest
@testable import WeatherApp

final class WeatherInsightsEngineTests: XCTestCase {
  func testUmbrellaCardRecommendsUmbrellaWhenRainRiskIsHigh() throws {
    let dashboard = try makeDashboard(forecastMain: "Rain", pop: 0.82)
    let umbrellaCard = try XCTUnwrap(dashboard.cards.first { $0.id == "umbrella" })

    XCTAssertEqual(umbrellaCard.title, "Şemsiye al")
    XCTAssertEqual(umbrellaCard.severity, .danger)
  }

  func testBestTimeCardProducesOutdoorWindow() throws {
    let dashboard = try makeDashboard(forecastMain: "Clear", pop: 0.05)
    let bestTimeCard = try XCTUnwrap(dashboard.cards.first { $0.id == "best-time" })

    XCTAssertEqual(bestTimeCard.title, "En iyi saat")
    XCTAssertFalse(dashboard.hourlyPlan.isEmpty)
  }

  private func makeDashboard(forecastMain: String, pop: Double) throws -> WeatherInsightDashboard {
    let currentJSON = """
    {
      "coord": {"lon": 29.0, "lat": 41.0},
      "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
      "main": {"temp": 22.0, "feels_like": 24.0, "humidity": 65},
      "wind": {"speed": 3.0},
      "sys": {"sunrise": 1893420000, "sunset": 1893470000},
      "name": "Istanbul",
      "cod": 200
    }
    """

    let forecastJSON = """
    {
      "cod": "200",
      "message": 0,
      "cnt": 2,
      "list": [
        {
          "dt": 1893456000,
          "main": {"temp": 22.0, "feels_like": 22.0, "humidity": 50},
          "weather": [{"id": 500, "main": "\(forecastMain)", "description": "light rain", "icon": "10d"}],
          "wind": {"speed": 4.0},
          "pop": \(pop)
        },
        {
          "dt": 1893466800,
          "main": {"temp": 21.0, "feels_like": 21.0, "humidity": 45},
          "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
          "wind": {"speed": 2.0},
          "pop": 0.02
        }
      ],
      "city": {"name": "Istanbul"}
    }
    """

    let decoder = JSONDecoder()
    let current = try decoder.decode(OpenWeatherMap.self, from: Data(currentJSON.utf8))
    let forecast = try decoder.decode(OpenWeatherMap.self, from: Data(forecastJSON.utf8))

    return WeatherInsightsEngine.makeDashboard(
      current: current,
      forecast: forecast,
      uvIndex: 4,
      now: Date(timeIntervalSince1970: 1893440000)
    )
  }
}
