import Foundation

enum ConstansKeys {
  static let accessToken = "unsplashAccessToken"
}

enum OAuth2Error: Error {
  case invalidURL
  case invalidResponse
  case decodingError
}

enum AuthServiceError: Error {
  case invalidRequest
}

final class OAuth2Service {
  static let shared = OAuth2Service()
  private var task: URLSessionTask?
  private var lastCode: String?

  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  private init() {}
  var accessToken: String? {
    retrieveAccessToken()
  }

  func getAccessToken(code: String, completion: @escaping (Result<Bool, Error>) -> Void) {
    assert(Thread.isMainThread)

    guard lastCode != code else {
      completion(.failure(AuthServiceError.invalidRequest))
      return
    }

    var request: URLRequest
    do {
      request = try getURLRequest(code: code)
    } catch {
      print("❌ Error creating URL request: \(error)")
      completion(.failure(error))
      return
    }

    task?.cancel()
    lastCode = code

    task = URLSession.shared.objectTask(for: request) {
      [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
      DispatchQueue.main.async { [weak self] in
        switch result {
        case .success(let tokenResponse):
          let accessToken = tokenResponse.accessToken
          self?.storeAccessToken(accessToken)
          completion(.success(true))
        case .failure(let error):
          print("Error fetching access token: \(error)")
          completion(.failure(error))
        }
        self?.task = nil
        self?.lastCode = nil
      }
    }

    task?.resume()
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
