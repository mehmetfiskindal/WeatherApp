//
//  APIKeySettingsView.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct APIKeySettingsView: View {
  @ObservedObject private var apiKeyStore = APIKeyStore.shared
  @State private var apiKey: String = ""

  var body: some View {
    NavigationStack {
      Form {
        Section {
          SecureField("OpenWeatherMap API Key", text: $apiKey)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

          Button("Kaydet") {
            apiKeyStore.save(apiKey)
            apiKey = ""
          }
          .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

          if apiKeyStore.apiKey != nil {
            Button("Kayıtlı Anahtarı Sil", role: .destructive) {
              apiKeyStore.delete()
            }
          }
        } footer: {
          Text(apiKeyStore.apiKey == nil ? "Hava durumu verilerini almak için OpenWeatherMap API key girin." : "API key Keychain içinde saklanıyor.")
        }
      }
      .navigationTitle("API Key")
    }
  }
}

#Preview {
  APIKeySettingsView()
}
