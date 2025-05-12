import Foundation

public protocol WebViewPresenterProtocol {
  var view: WebViewViewControllerProtocol? { get set }
  func viewDidLoad()
}

final class WebViewPresenter: WebViewPresenterProtocol {
  weak var view: WebViewViewControllerProtocol?

  func viewDidLoad() {
    guard let baseUrl = Constants.defaultBaseURL else {
      print("❌ Error: Base URL is nil")
      return
    }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = "/oauth/authorize"
    urlComponents?.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: Constants.accessScope),

      if let url = urlComponents?.url {
        let request = URLRequest(url: url)
        view?.load(request: request)
      } else {
        print("❌ Error creating URL from components")
      },
    ]
  }

}
