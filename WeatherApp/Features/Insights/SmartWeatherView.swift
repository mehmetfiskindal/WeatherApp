//
//  SmartWeatherView.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import CoreLocation
import SwiftUI

struct SmartWeatherView: View {
  @Environment(\.colorScheme) private var colorScheme
  @StateObject private var viewModel = SmartWeatherViewModel()
  @StateObject private var locationManager = LocationManager()
  @State private var showsAPIKeySettings = false
  @FocusState private var isSearchFocused: Bool

  private var theme: WeatherTheme {
    viewModel.currentDashboard?.theme ?? WeatherTheme.defaultTheme(for: colorScheme)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        WeatherGradientBackground(theme: theme)

        ScrollView {
          VStack(alignment: .leading, spacing: WeatherSpacing.lg) {
            searchPanel
            content
          }
          .padding(WeatherSpacing.md)
          .animation(.easeInOut(duration: 0.24), value: viewModel.stateID)
        }
      }
      .navigationTitle("Akıllı Plan")
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showsAPIKeySettings = true
          } label: {
            Image(systemName: "key.fill")
          }
          .accessibilityLabel("API key ayarları")
        }
      }
      .sheet(isPresented: $showsAPIKeySettings) {
        APIKeySettingsView()
      }
      .onChange(of: locationManager.location) { newLocation in
        guard let newLocation else { return }
        Task {
          await viewModel.load(location: newLocation)
        }
      }
    }
  }

  private var searchPanel: some View {
    WeatherGlassCard(theme: theme) {
      VStack(alignment: .leading, spacing: WeatherSpacing.md) {
        Text("Bugün ne yapmalı?")
          .font(WeatherTypography.title)
          .foregroundStyle(theme.textPrimary)

        HStack(spacing: WeatherSpacing.sm) {
          TextField("Şehir adı", text: $viewModel.searchText)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($isSearchFocused)
            .submitLabel(.search)
            .onSubmit {
              loadCity()
            }
            .padding(WeatherSpacing.md)
            .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
            .foregroundStyle(theme.textPrimary)

          Button {
            loadCity()
          } label: {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 18, weight: .semibold))
              .frame(width: 48, height: 48)
          }
          .buttonStyle(.plain)
          .foregroundStyle(theme.textPrimary)
          .background(theme.accent, in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
          .accessibilityLabel("Şehir için önerileri getir")
        }

        Button {
          locationManager.requestLocation()
        } label: {
          Label(locationButtonTitle, systemImage: "location.fill")
            .font(WeatherTypography.bodyStrong)
            .frame(maxWidth: .infinity)
            .padding(.vertical, WeatherSpacing.sm)
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.textPrimary)
        .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: WeatherRadius.md, style: .continuous))
        .accessibilityHint("Konum izni verildiyse mevcut konuma göre hava planı oluşturur.")

        if let errorMessage = locationManager.errorMessage {
          Text(errorMessage)
            .font(WeatherTypography.caption)
            .foregroundStyle(WeatherColor.warning)
        }
      }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.state {
    case .empty:
      stateCard(
        icon: "sparkles",
        title: "Şehir yaz veya konumunu kullan",
        message: "Şemsiye, kıyafet, UV, rüzgar ve saatlik plan önerilerini tek ekranda göreceksin."
      )
    case .loading:
      WeatherGlassCard(theme: theme) {
        HStack(spacing: WeatherSpacing.md) {
          ProgressView()
            .tint(theme.textPrimary)
          Text("Hava planı hazırlanıyor...")
            .font(WeatherTypography.bodyStrong)
            .foregroundStyle(theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    case .error(let message, let cached):
      if let cached {
        dashboardContent(cached, isCached: true)
      }
      stateCard(
        icon: "exclamationmark.triangle.fill",
        title: "Veri alınamadı",
        message: message
      )
    case .loaded(let dashboard, let isCached):
      dashboardContent(dashboard, isCached: isCached)
    }
  }

  private func dashboardContent(_ dashboard: WeatherInsightDashboard, isCached: Bool) -> some View {
    VStack(alignment: .leading, spacing: WeatherSpacing.lg) {
      WeatherGlassCard(theme: dashboard.theme) {
        SmartWeatherHeroView(dashboard: dashboard, isCached: isCached)
      }

      section("Karar Kartları") {
        ForEach(dashboard.cards) { card in
          WeatherInsightCardView(card: card, theme: dashboard.theme)
        }
      }

      section("Risk Kartları") {
        ForEach(dashboard.riskCards) { card in
          WeatherInsightCardView(card: card, theme: dashboard.theme)
        }
      }

      section("Saatlik Plan") {
        ForEach(dashboard.hourlyPlan) { item in
          HourlyPlanRow(item: item, theme: dashboard.theme)
        }
      }
    }
  }

  private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: WeatherSpacing.sm) {
      Text(title)
        .font(WeatherTypography.subtitle)
        .foregroundStyle(theme.textPrimary)
        .accessibilityAddTraits(.isHeader)

      content()
    }
  }

  private func stateCard(icon: String, title: String, message: String) -> some View {
    WeatherGlassCard(theme: theme) {
      VStack(alignment: .leading, spacing: WeatherSpacing.sm) {
        Image(systemName: icon)
          .font(.system(size: 28, weight: .semibold))
          .foregroundStyle(theme.accent)

        Text(title)
          .font(WeatherTypography.title)
          .foregroundStyle(theme.textPrimary)

        Text(message)
          .font(WeatherTypography.body)
          .foregroundStyle(theme.textSecondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var locationButtonTitle: String {
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      return "Konumumdan öneri al"
    case .denied, .restricted:
      return "Konum izni kapalı"
    case .notDetermined:
      return "Konum izni ver"
    @unknown default:
      return "Konumumdan öneri al"
    }
  }

  private func loadCity() {
    isSearchFocused = false
    Task {
      await viewModel.load(city: viewModel.searchText)
    }
  }
}

#Preview {
  SmartWeatherView()
}
