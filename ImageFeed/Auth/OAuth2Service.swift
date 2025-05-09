import Foundation

enum ConstansKeys {
  static let accessToken = "unsplashAccessToken"
}

enum OAuth2Error: Error {
  case invalidURL
  case invalidResponse
  case decodingError
}

final class OAuth2Service {
  static let shared = OAuth2Service()
  private init() {}
  var accessToken: String? {
    retrieveAccessToken()
  }

  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func getAccessToken(code: String, completion: @escaping (Result<Bool, Error>) -> Void) {
    var request: URLRequest
    do {
      request = try getURLRequest(code: code)
    } catch {
      print("❌ Error creating URL request: \(error)")
      completion(.failure(error))
      return
    }
    let task = URLSession.shared.data(for: request) { result in
      switch result {
      case .success(let data):
        do {
          let tokenResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
          let accessToken = tokenResponse.accessToken
          self.storeAccessToken(accessToken)
          completion(.success(true))
        } catch {
          print("❌ Error decoding token response: \(error)")
          completion(.failure(error))
        }
      case .failure(let error):
        print("❌ Error fetching access token: \(error)")
        completion(.failure(error))
      }
    }

    task.resume()
  }

  private func getURLRequest(code: String) throws -> URLRequest {
    guard let baseUrl = Constants.defaultBaseURL else {
      print("❌ Error: Base URL is nil")
      throw OAuth2Error.invalidURL
    }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = "/oauth/token"
    urlComponents?.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "client_secret", value: Constants.secretKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "code", value: code),
      URLQueryItem(name: "grant_type", value: "authorization_code"),
    ]
    guard let url = urlComponents?.url else {
      print("❌ Error creating URL from components")
      throw OAuth2Error.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    return request
  }

  private func storeAccessToken(_ token: String) {
    // TODO: Store the access token securely
    UserDefaults.standard.set(token, forKey: ConstansKeys.accessToken)
  }

  private func retrieveAccessToken() -> String? {
    UserDefaults.standard.string(forKey: ConstansKeys.accessToken)
  }

  private func clearAccessToken() {
    UserDefaults.standard.removeObject(forKey: ConstansKeys.accessToken)
  }

  func isLoggedIn() -> Bool {
    retrieveAccessToken() != nil
  }

  func logout() {
    clearAccessToken()
    transitionToViewController(viewController: SplashViewController())
  }

}
