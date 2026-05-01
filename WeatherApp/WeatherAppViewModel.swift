import Foundation
import Connectivity

class WeatherAppViewModel: ObservableObject {
  @Published var isConnected = true
  private let connectivity = Connectivity()

  init() {
    setupConnectivity()
  }
  func getApiKey() {
    APIKeyStore.shared.migrateBundledAPIKeyIfNeeded()
  }
  func setupConnectivity() {
    connectivity.whenConnected = { [weak self] _ in
      self?.updateConnectionStatus(true)
    }

    connectivity.whenDisconnected = { [weak self] _ in
      self?.updateConnectionStatus(false)
    }

    // Bağlantıyı izlemeye başla
    connectivity.startNotifier()
  }

  func updateConnectionStatus(_ isConnected: Bool) {
    DispatchQueue.main.async {
      self.isConnected = isConnected
    }
  }
  func restartConnectivity() {
    connectivity.stopNotifier() // Önceki bağlantı izlemeyi durdur
    setupConnectivity() // Yeni bağlantı izlemeyi başlat
  }
}
