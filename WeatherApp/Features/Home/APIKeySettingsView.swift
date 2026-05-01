//
//  APIKeySettingsView.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import SwiftUI

struct APIKeySettingsView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  @ObservedObject private var apiKeyStore = APIKeyStore.shared
  @State private var apiKey: String = ""

  private var theme: WeatherTheme {
    WeatherTheme.defaultTheme(for: colorScheme)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        WeatherGradientBackground(theme: theme)

        ScrollView {
          VStack(alignment: .leading, spacing: WeatherSpacing.lg) {
            WeatherGlassCard(theme: theme) {
              VStack(alignment: .leading, spacing: WeatherSpacing.md) {
                Image(systemName: "key.fill")
                  .font(.system(size: 32, weight: .semibold))
                  .foregroundStyle(theme.accent)

                Text("OpenWeatherMap API Key")
                  .font(WeatherTypography.title)
                  .foregroundStyle(theme.textPrimary)
                  .accessibilityAddTraits(.isHeader)

                Text(apiKeyStore.apiKey == nil ? "Hava planını oluşturmak için API key girmen gerekiyor." : "API key Keychain içinde güvenli şekilde saklanıyor.")
                  .font(WeatherTypography.body)
                  .foregroundStyle(theme.textSecondary)
                  .fixedSize(horizontal: false, vertical: true)

                SecureField("API key", text: $apiKey)
                  .textInputAutocapitalization(.never)
                  .autocorrectionDisabled()
                  .textContentType(.password)
                  .submitLabel(.done)
                  .onSubmit(saveAPIKey)
                  .padding(WeatherSpacing.md)
                  .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
                  .foregroundStyle(theme.textPrimary)
                  .accessibilityLabel("OpenWeatherMap API key")

                WeatherPrimaryButton("Kaydet", systemImage: "checkmark", theme: theme) {
                  saveAPIKey()
                }
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)

                if apiKeyStore.apiKey != nil {
                  Button(role: .destructive) {
                    apiKeyStore.delete()
                    apiKey = ""
                  } label: {
                    Label("Kayıtlı anahtarı sil", systemImage: "trash")
                      .font(WeatherTypography.bodyStrong)
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, WeatherSpacing.md)
                  }
                  .buttonStyle(.plain)
                  .foregroundStyle(WeatherColor.danger)
                  .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
                }
              }
            }

            WeatherGlassCard(theme: theme) {
              Text("API key repoya, Info.plist'e veya UserDefaults'a yazılmaz; KeychainAccess ile cihaz Keychain'inde tutulur.")
                .font(WeatherTypography.caption)
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
          .padding(WeatherSpacing.md)
        }
      }
      .navigationTitle("API Key")
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          if apiKeyStore.apiKey != nil {
            Button("Kapat") {
              dismiss()
            }
          }
        }
      }
    }
  }

  private func saveAPIKey() {
    let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedKey.isEmpty else { return }
    apiKeyStore.save(trimmedKey)
    apiKey = ""
    dismiss()
  }
}

#Preview {
  APIKeySettingsView()
}
