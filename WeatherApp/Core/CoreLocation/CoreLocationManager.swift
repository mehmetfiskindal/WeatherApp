//
//  CoreLocationManager.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 17.02.2024.
//
import CoreLocation
import Combine
import MapKit

import Foundation
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private var locationManager = CLLocationManager()
  @Published var onLocationUpdate: ((Result<String, Error>) -> Void)?
  @Published var location: CLLocation?
  @Published var authorizationStatus: CLAuthorizationStatus
  @Published var errorMessage: String?

  override init() {
    authorizationStatus = locationManager.authorizationStatus
    super.init()
    locationManager.delegate = self
  }

  func requestLocation() {
    authorizationStatus = locationManager.authorizationStatus

    switch authorizationStatus {
    case .notDetermined:
      errorMessage = nil
      locationManager.requestWhenInUseAuthorization()
    case .authorizedAlways, .authorizedWhenInUse:
      errorMessage = nil
      locationManager.requestLocation()
    case .denied, .restricted:
      errorMessage = "Konum izni kapalı. Ayarlardan izin verebilir veya şehir adı yazabilirsin."
    @unknown default:
      errorMessage = "Konum izni durumu okunamadı."
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      self.location = location
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
      manager.requestLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    errorMessage = error.localizedDescription
    onLocationUpdate?(.failure(error))
  }
}
