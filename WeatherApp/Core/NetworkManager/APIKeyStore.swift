//
//  APIKeyStore.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 1.05.2026.
//

import Foundation
import KeychainAccess

final class APIKeyStore: ObservableObject {
  static let shared = APIKeyStore()

  private enum Constants {
    static let keychainService = "com.fiskindal.WeatherApp.openweathermap"
    static let apiKey = "apiKey"
    static let legacyUserDefaultsKey = "key"
  }

  private let keychain = Keychain(service: Constants.keychainService)
    .accessibility(.afterFirstUnlock)

  @Published private(set) var apiKey: String?

  private init() {
    apiKey = try? keychain.getString(Constants.apiKey)
  }

  func save(_ apiKey: String) {
    let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedKey.isEmpty else { return }

    do {
      try keychain.set(trimmedKey, key: Constants.apiKey)
      self.apiKey = trimmedKey
      UserDefaults.standard.removeObject(forKey: Constants.legacyUserDefaultsKey)
    } catch {
      print("API key could not be saved: \(error)")
    }
  }

  func delete() {
    do {
      try keychain.remove(Constants.apiKey)
      apiKey = nil
    } catch {
      print("API key could not be deleted: \(error)")
    }
  }

  func migrateBundledAPIKeyIfNeeded() {
    guard apiKey == nil else { return }

    if let plistPath = Bundle.main.path(forResource: "Keys", ofType: "plist"),
      let keys = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
      let bundledAPIKey = keys[Constants.legacyUserDefaultsKey] as? String {
      save(bundledAPIKey)
      return
    }

    if let legacyAPIKey = UserDefaults.standard.string(forKey: Constants.legacyUserDefaultsKey) {
      save(legacyAPIKey)
    }
  }
}
