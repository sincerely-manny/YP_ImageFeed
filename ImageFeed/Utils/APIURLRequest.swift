import Foundation

final class APIURLRequest {
  private static let oauth2Service = OAuth2Service.shared

  static func getURLRequest(for endpoint: String) -> URLRequest? {
    guard let baseUrl = Constants.apiBaseURL else { return nil }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = endpoint
    guard let url = urlComponents?.url else { return nil }
    var request = URLRequest(url: url)
    guard oauth2Service.isLoggedIn() else {
      print("❌ Error: User is not logged in")
      return nil
    }
    request.setValue(
      "Bearer \(oauth2Service.accessToken ?? "")", forHTTPHeaderField: "Authorization")
    request.httpMethod = HTTPMethod.get.rawValue
    return request
  }
}
