import Foundation

final class APIURLRequest {
  private static let oauth2Service = OAuth2Service.shared

  static func getURLRequest(for endpoint: String, params: [String: String]? = [:]) -> URLRequest? {
    guard let baseUrl = Constants.apiBaseURL else { return nil }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = endpoint
    if let params = params, !params.isEmpty {
      var queryItems = [URLQueryItem]()
      params.forEach { key, value in
        let queryItem = URLQueryItem(name: key, value: value)
        queryItems.append(queryItem)
      }
      urlComponents?.queryItems = queryItems
    }

    guard let url = urlComponents?.url else { return nil }
    var request = URLRequest(url: url)
    guard oauth2Service.isLoggedIn() else {
      print("❌ Error: User is not logged in")
      return nil
    }
    request.setValue(
      "Bearer \(oauth2Service.accessToken ?? "")", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
    return request
  }
}
