import Foundation

let ACCESS_TOKEN_STORED_KEY = "unsplashAccessToken"

enum AuthServiceError: Error {
  case invalidRequest
}

final class OAuth2Service {
  static let shared = OAuth2Service()
  private var task: URLSessionTask?
  private var lastCode: String?

  private init() {}
  var accessToken: String? {
    retrieveAccessToken()
  }

  func getAccessToken(code: String, completion: @escaping (Result<Bool, Error>) -> Void) {
    assert(Thread.isMainThread)
    guard let request = getURLRequest(code: code) else { return }

    guard lastCode != code else {
      completion(.failure(AuthServiceError.invalidRequest))
      return
    }

    task?.cancel()
    lastCode = code

    task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          print("Error fetching access token: \(error)")
          completion(.failure(error))
        } else if let data = data {
          do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            let accessToken = tokenResponse.accessToken
            self?.storeAccessToken(accessToken)
            completion(.success(true))
          } catch {
            print("Error decoding token response: \(error)")
            completion(.failure(error))
          }
        } else {
          completion(.failure(AuthServiceError.invalidRequest))
        }
        self?.task = nil
        self?.lastCode = nil
      }
    }
    task?.resume()
  }

  private func getURLRequest(code: String) -> URLRequest? {
    guard let baseUrl = Constants.defaultBaseURL else { return nil }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = "/oauth/token"
    urlComponents?.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "client_secret", value: Constants.secretKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "code", value: code),
      URLQueryItem(name: "grant_type", value: "authorization_code"),
    ]
    guard let url = urlComponents?.url else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    return request
  }

  private func storeAccessToken(_ token: String) {
    // TODO: Store the access token securely
    UserDefaults.standard.set(token, forKey: ACCESS_TOKEN_STORED_KEY)
  }

  private func retrieveAccessToken() -> String? {
    UserDefaults.standard.string(forKey: ACCESS_TOKEN_STORED_KEY)
  }

  private func clearAccessToken() {
    UserDefaults.standard.removeObject(forKey: ACCESS_TOKEN_STORED_KEY)
  }

  func isLoggedIn() -> Bool {
    retrieveAccessToken() != nil
  }

}

struct OAuthTokenResponseBody: Decodable {
  let accessToken: String
  let tokenType: String
  let scope: String
  let createdAt: Int

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case scope
    case createdAt = "created_at"
  }
}
