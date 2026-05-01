//
//  INetworkManager.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 17.02.2024.
//

import Foundation
import Alamofire
protocol INetworkManager {
  func fetch<T: Codable>(path: NetworkPath, method: HTTPMethod, type: T.Type) async -> T?
  func fetchResult<T: Codable>(path: NetworkPath, method: HTTPMethod, type: T.Type) async -> Result<T, WeatherAPIError>
  func post<T: Codable, R: Encodable>(path: NetworkPath, model: R, type: T.Type) async -> T?
  var config: NetworkConfig { get set }
}
