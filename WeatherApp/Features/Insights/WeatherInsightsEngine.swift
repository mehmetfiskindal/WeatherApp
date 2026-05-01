//
//  WeatherInsightsEngine.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import Foundation

enum WeatherInsightsEngine {
  static func makeDashboard(
    current: OpenWeatherMap,
    forecast: OpenWeatherMap,
    uvIndex: Double?,
    now: Date = Date(),
    calendar: Calendar = .current
  ) -> WeatherInsightDashboard {
    let slots = (forecast.list ?? [])
      .compactMap(ForecastSlot.init)
      .filter { $0.date >= now }
      .sorted { $0.date < $1.date }

    let currentTemp = celsius(current.main?.temp)
    let feelsLike = celsius(current.main?.feelsLike ?? current.main?.temp)
    let condition = current.weather?.first?.main ?? slots.first?.condition ?? "Clear"
    let theme = WeatherTheme.theme(for: WeatherCondition(openWeatherMain: condition, isNight: isNight(current: current, now: now, calendar: calendar)))
    let bestSlot = slots.max { score($0, uvIndex: uvIndex) < score($1, uvIndex: uvIndex) }
    let rainRisk = max(slots.prefix(4).map(\.pop).max() ?? 0, immediateRainRisk(current: current))
    let windSpeed = current.wind?.speed ?? slots.first?.windSpeed ?? 0

    let summary = makeSummary(bestSlot: bestSlot, rainRisk: rainRisk, windSpeed: windSpeed, uvIndex: uvIndex, calendar: calendar)
    let cards = [
      umbrellaCard(rainRisk: rainRisk, condition: condition),
      bestTimeCard(bestSlot: bestSlot, uvIndex: uvIndex, calendar: calendar),
      feelsLikeCard(temp: currentTemp, feelsLike: feelsLike, humidity: current.main?.humidity, windSpeed: windSpeed),
      clothingCard(feelsLike: feelsLike, rainRisk: rainRisk, windSpeed: windSpeed)
    ]

    let riskCards = [
      rainRiskCard(rainRisk: rainRisk),
      windRiskCard(windSpeed: windSpeed),
      uvRiskCard(uvIndex: uvIndex)
    ]

    return WeatherInsightDashboard(
      cityName: current.name ?? forecast.city?.name ?? "Konum",
      temperatureText: "\(Int(round(currentTemp)))°",
      conditionText: current.weather?.first?.description?.capitalized ?? condition,
      summary: summary,
      theme: theme,
      cards: cards,
      riskCards: riskCards,
      hourlyPlan: hourlyPlan(from: slots, uvIndex: uvIndex, calendar: calendar)
    )
  }

  static func celsius(_ value: Double?) -> Double {
    guard let value else { return 0 }
    return value > 100 ? value - 273.15 : value
  }

  private static func makeSummary(bestSlot: ForecastSlot?, rainRisk: Double, windSpeed: Double, uvIndex: Double?, calendar: Calendar) -> String {
    guard let bestSlot else {
      return "Bugün için yeterli saatlik tahmin yok. Biraz sonra tekrar deneyebilirsin."
    }

    let time = timeRange(for: bestSlot.date, calendar: calendar)
    if rainRisk >= 0.55 {
      return "Bugün dışarı çıkarken yağış planı yap. En uygun aralık \(time), ama şemsiye yanında olsun."
    }
    if (uvIndex ?? 0) >= 7 {
      return "\(time) arası dışarı çıkmak uygun; UV yüksek olduğu için güneş kremi ve gölge molası iyi olur."
    }
    if windSpeed >= 9 {
      return "\(time) arası kısa işler için uygun, fakat rüzgar hissedilir seviyede."
    }
    return "Bugün \(time) arası yürüyüş için uygun. Rüzgar düşük, yağış ihtimali az."
  }

  private static func umbrellaCard(rainRisk: Double, condition: String) -> WeatherInsightCard {
    let rainyCondition = ["rain", "drizzle", "thunderstorm", "snow"].contains(condition.lowercased())
    if rainRisk >= 0.45 || rainyCondition {
      return WeatherInsightCard(
        id: "umbrella",
        title: "Şemsiye al",
        message: "Önümüzdeki saatlerde yağış ihtimali \(percent(rainRisk)). Çantaya küçük bir şemsiye koymak mantıklı.",
        systemImage: "umbrella.fill",
        severity: rainRisk >= 0.7 ? .danger : .warning
      )
    }

    return WeatherInsightCard(
      id: "umbrella",
      title: "Şemsiye gerekmeyebilir",
      message: "Yakın saatlerde yağış ihtimali düşük görünüyor: \(percent(rainRisk)).",
      systemImage: "checkmark.circle.fill",
      severity: .good
    )
  }

  private static func bestTimeCard(bestSlot: ForecastSlot?, uvIndex: Double?, calendar: Calendar) -> WeatherInsightCard {
    guard let bestSlot else {
      return WeatherInsightCard(
        id: "best-time",
        title: "Saat önerisi yok",
        message: "Saatlik tahmin verisi gelmediği için net bir dışarı çıkma aralığı öneremiyorum.",
        systemImage: "clock.badge.questionmark",
        severity: .info
      )
    }

    let scoreValue = score(bestSlot, uvIndex: uvIndex)
    return WeatherInsightCard(
      id: "best-time",
      title: "En iyi saat",
      message: "\(timeRange(for: bestSlot.date, calendar: calendar)) arası dışarı çıkmak için en dengeli aralık. Uygunluk skoru \(Int(scoreValue))/100.",
      systemImage: "figure.walk.circle.fill",
      severity: scoreValue >= 70 ? .good : .info
    )
  }

  private static func feelsLikeCard(temp: Double, feelsLike: Double, humidity: Int?, windSpeed: Double) -> WeatherInsightCard {
    let difference = feelsLike - temp
    let title = "Hissedilen neden farklı?"
    let message: String

    if abs(difference) < 2 {
      message = "Hissedilen sıcaklık gerçek sıcaklığa yakın. Nem ve rüzgar bugün büyük fark yaratmıyor."
    } else if difference < 0 {
      message = "Rüzgar \(speed(windSpeed)) seviyesinde olduğu için hava \(Int(abs(difference)))° daha serin hissediliyor."
    } else {
      let humidityText = humidity.map { "\($0)%" } ?? "yüksek"
      message = "Nem \(humidityText) olduğu için hava termometreden daha sıcak hissediliyor."
    }

    return WeatherInsightCard(
      id: "feels-like",
      title: title,
      message: message,
      systemImage: "thermometer.medium",
      severity: .info
    )
  }

  private static func clothingCard(feelsLike: Double, rainRisk: Double, windSpeed: Double) -> WeatherInsightCard {
    var pieces: [String]
    switch feelsLike {
    case ..<5:
      pieces = ["kalın mont", "atkı"]
    case 5..<12:
      pieces = ["mont", "katmanlı üst"]
    case 12..<20:
      pieces = ["ince ceket", "rahat ayakkabı"]
    case 20..<28:
      pieces = ["hafif üst", "güneş gözlüğü"]
    default:
      pieces = ["ince ve nefes alan kıyafet", "su şişesi"]
    }

    if rainRisk >= 0.35 {
      pieces.append("su geçirmez dış katman")
    }
    if windSpeed >= 8 {
      pieces.append("rüzgar kesen ceket")
    }

    return WeatherInsightCard(
      id: "clothing",
      title: "Kıyafet önerisi",
      message: pieces.joined(separator: ", ").capitalized + " iyi olur.",
      systemImage: "tshirt.fill",
      severity: .info
    )
  }

  private static func rainRiskCard(rainRisk: Double) -> WeatherInsightCard {
    WeatherInsightCard(
      id: "rain-risk",
      title: "Yağmur riski",
      message: "Yakın saatlerde yağış ihtimali \(percent(rainRisk)).",
      systemImage: "cloud.rain.fill",
      severity: rainRisk >= 0.65 ? .danger : rainRisk >= 0.35 ? .warning : .good
    )
  }

  private static func windRiskCard(windSpeed: Double) -> WeatherInsightCard {
    WeatherInsightCard(
      id: "wind-risk",
      title: "Rüzgar",
      message: "Rüzgar \(speed(windSpeed)). \(windSpeed >= 9 ? "Açık alanda hissedilir." : "Dışarı planını çok zorlamaz.")",
      systemImage: "wind",
      severity: windSpeed >= 12 ? .danger : windSpeed >= 8 ? .warning : .good
    )
  }

  private static func uvRiskCard(uvIndex: Double?) -> WeatherInsightCard {
    guard let uvIndex else {
      return WeatherInsightCard(
        id: "uv-risk",
        title: "UV",
        message: "UV verisi alınamadı. Güneşli havada koruma kullanmak güvenli seçim.",
        systemImage: "sun.max.fill",
        severity: .info
      )
    }

    return WeatherInsightCard(
      id: "uv-risk",
      title: "UV",
      message: "UV indeksi \(String(format: "%.1f", uvIndex)). \(uvIndex >= 6 ? "Güneş kremi ve gölge molası önerilir." : "Risk düşük-orta seviyede.")",
      systemImage: "sun.max.fill",
      severity: uvIndex >= 8 ? .danger : uvIndex >= 6 ? .warning : .good
    )
  }

  private static func hourlyPlan(from slots: [ForecastSlot], uvIndex: Double?, calendar: Calendar) -> [HourlyPlanItem] {
    slots.prefix(6).map { slot in
      let scoreValue = Int(score(slot, uvIndex: uvIndex))
      let title: String
      let icon: String

      if scoreValue >= 75 {
        title = "Yürüyüş için uygun"
        icon = "figure.walk"
      } else if scoreValue >= 55 {
        title = "Kısa dış işler"
        icon = "bag.fill"
      } else {
        title = "İç mekan daha iyi"
        icon = "house.fill"
      }

      return HourlyPlanItem(
        id: "\(slot.date.timeIntervalSince1970)",
        timeRange: timeRange(for: slot.date, calendar: calendar),
        title: title,
        detail: "\(Int(round(slot.temperature)))°, yağış \(percent(slot.pop)), rüzgar \(speed(slot.windSpeed))",
        systemImage: icon,
        score: scoreValue
      )
    }
  }

  private static func score(_ slot: ForecastSlot, uvIndex: Double?) -> Double {
    let comfortPenalty = min(abs(slot.temperature - 21) * 2.2, 35)
    let rainPenalty = slot.pop * 55
    let windPenalty = max(slot.windSpeed - 4, 0) * 4
    let uvPenalty = max((uvIndex ?? 0) - 6, 0) * 4
    let conditionPenalty = ["rain", "drizzle", "thunderstorm", "snow"].contains(slot.condition.lowercased()) ? 22.0 : 0

    return max(0, min(100, 100 - comfortPenalty - rainPenalty - windPenalty - uvPenalty - conditionPenalty))
  }

  private static func immediateRainRisk(current: OpenWeatherMap) -> Double {
    let condition = current.weather?.first?.main?.lowercased()
    if condition == "thunderstorm" { return 0.9 }
    if condition == "rain" || condition == "drizzle" { return 0.7 }
    if condition == "snow" { return 0.55 }
    return 0
  }

  private static func timeRange(for date: Date, calendar: Calendar) -> String {
    let endDate = calendar.date(byAdding: .hour, value: 3, to: date) ?? date
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return "\(formatter.string(from: date))-\(formatter.string(from: endDate))"
  }

  private static func percent(_ value: Double) -> String {
    "\(Int(round(value * 100)))%"
  }

  private static func speed(_ value: Double) -> String {
    "\(String(format: "%.1f", value)) m/sn"
  }

  private static func isNight(current: OpenWeatherMap, now: Date, calendar: Calendar) -> Bool {
    if let sunrise = current.sys?.sunrise, let sunset = current.sys?.sunset {
      let timestamp = now.timeIntervalSince1970
      return timestamp < Double(sunrise) || timestamp > Double(sunset)
    }

    let hour = calendar.component(.hour, from: now)
    return hour < 6 || hour >= 20
  }
}

private struct ForecastSlot {
  let date: Date
  let temperature: Double
  let pop: Double
  let windSpeed: Double
  let condition: String

  init?(_ item: Liste) {
    guard let timestamp = item.dt else { return nil }
    date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    temperature = WeatherInsightsEngine.celsius(item.main?.feelsLike ?? item.main?.temp)
    pop = item.pop ?? 0
    windSpeed = item.wind?.speed ?? 0
    condition = item.weather?.first?.main ?? "Clear"
  }
}
