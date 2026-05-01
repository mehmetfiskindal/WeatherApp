//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 29.07.2023.
//
import CoreLocation
import Alamofire
import Foundation

enum WeatherAPIError: LocalizedError {
  case invalidURL
  case emptyResponse
  case requestFailed(String)

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "İstek adresi hazırlanamadı."
    case .emptyResponse:
      return "Sunucudan veri alınamadı."
    case .requestFailed(let message):
      return message
    }
  }
}

class NetworkManager: INetworkManager {
  internal var config: NetworkConfig

  init(config: NetworkConfig) {
    self.config = config
  }

  func fetch<T: Codable>(path: NetworkPath, method: HTTPMethod, type: T.Type) async -> T? {
    let result: Result<T, WeatherAPIError> = await fetchResult(path: path, method: method, type: type)

    switch result {
    case .success(let value):
      return value
    case .failure(let error):
      print("ERROR: \(error.localizedDescription)")
      return nil
    }
  }

  func fetchResult<T: Codable>(path: NetworkPath, method: HTTPMethod, type: T.Type) async -> Result<T, WeatherAPIError> {
    let urlString = "\(config.baseUrl)\(path.rawValue)"
    guard URL(string: urlString) != nil else {
      return .failure(.invalidURL)
    }

    let dataRequest = AF.request(urlString, method: method)
      .validate()
      .serializingDecodable(T.self)

    let result = await dataRequest.response

    if let value = result.value {
      return .success(value)
    }

    if let error = result.error {
      return .failure(.requestFailed(error.localizedDescription))
    }

    return .failure(.emptyResponse)
  }

  func post<T: Codable, R: Encodable>(path: NetworkPath, model: R, type: T.Type) async -> T? {
    let jsonEncoder = JSONEncoder()
    //        thread
    guard let data = try? jsonEncoder.encode(model) else { return nil }
    guard let dataString = String(data: data, encoding: .utf8) else { return nil }
    let dataRequest = AF.request("\(config.baseUrl)\(path.rawValue)", method: .post, parameters: convertToDictionary(text: dataString))
      .validate()
      .serializingDecodable(T.self)
    let result = await dataRequest.response

    guard let value = result.value else {
      print("ERROR: \(String(describing: result.error))")
      return nil
    }

    return value
  }

  private func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
}

struct NetworkConfig {
  let baseUrl: String
}

extension NetworkManager {
  static let networkManager: INetworkManager = NetworkManager(config: NetworkConfig(baseUrl: NetworkPath.baseUrl))
}
