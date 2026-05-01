//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 22.07.2023.
//

import SwiftUI

@main
struct WeatherApp: App {
  @ObservedObject var _viewModel = WeatherAppViewModel()
  init() {
    _viewModel.getApiKey()
  }
  var body: some Scene {
    WindowGroup {
      if _viewModel.isConnected {
        HomeView()
      }
      else {
        NetworkUnavailableView {
          _viewModel.restartConnectivity()
        }
      }
    }
  }
}

private struct NetworkUnavailableView: View {
  let retry: () -> Void

  var body: some View {
    ZStack {
      WeatherGradientBackground(theme: .night)

      WeatherGlassCard(theme: .night) {
        VStack(alignment: .leading, spacing: WeatherSpacing.md) {
          Image(systemName: "wifi.exclamationmark")
            .font(.system(size: 36, weight: .semibold))
            .foregroundStyle(WeatherColor.warning)

          Text("İnternet bağlantısı yok")
            .font(WeatherTypography.title)
            .foregroundStyle(WeatherTheme.night.textPrimary)

          Text("Hava planını hazırlamak için bağlantı gerekiyor. Bağlantını kontrol edip tekrar deneyebilirsin.")
            .font(WeatherTypography.body)
            .foregroundStyle(WeatherTheme.night.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

          WeatherPrimaryButton("Yeniden dene", systemImage: "arrow.clockwise", theme: .night, action: retry)
        }
      }
      .padding(WeatherSpacing.md)
    }
  }
}

#Preview {
  HomeView()
}
