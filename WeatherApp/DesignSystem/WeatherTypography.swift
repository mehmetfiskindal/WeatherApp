//
//  WeatherTypography.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

enum WeatherTypography {
  static let heroTemperature = SwiftUI.Font.system(size: 88, weight: .thin, design: .rounded)
  static let heroTitle = SwiftUI.Font.system(.largeTitle, design: .rounded).weight(.semibold)
  static let title = SwiftUI.Font.system(.title2, design: .rounded).weight(.semibold)
  static let subtitle = SwiftUI.Font.system(.headline, design: .rounded).weight(.medium)
  static let body = SwiftUI.Font.system(.body, design: .rounded)
  static let bodyStrong = SwiftUI.Font.system(.body, design: .rounded).weight(.semibold)
  static let caption = SwiftUI.Font.system(.caption, design: .rounded).weight(.medium)
  static let metricValue = SwiftUI.Font.system(.title3, design: .rounded).weight(.semibold)
}
