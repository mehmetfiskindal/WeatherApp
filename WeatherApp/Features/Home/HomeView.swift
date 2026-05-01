//
//  HomeView.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 2.09.2023.
//

import SwiftUI

struct HomeView: View {
  @ObservedObject private var apiKeyStore = APIKeyStore.shared

  var body: some View {
    if apiKeyStore.apiKey == nil {
      APIKeySettingsView()
    } else {
      TabView {
        VStack {
          WeatherView()

        }.tabItem {
          Label("Anasayfa", systemImage: "house")
        }
        MyWeatherView()
          .tabItem {
          Label("Konumum", systemImage: "location")
        }

        ForecastView()
          .tabItem {
          Label("Haftalık", systemImage: "calendar")
        }

        APIKeySettingsView()
          .tabItem {
            Label("API Key", systemImage: "key")
          }
      }
    }
  }
}

#Preview {
  HomeView()
}
