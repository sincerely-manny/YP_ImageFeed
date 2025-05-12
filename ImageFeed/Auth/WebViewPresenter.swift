import Foundation

public protocol WebViewPresenterProtocol {
  var view: WebViewViewControllerProtocol? { get set }
  func viewDidLoad()
  func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewPresenter: WebViewPresenterProtocol {
  weak var view: WebViewViewControllerProtocol?

  func viewDidLoad() {
    guard let baseUrl = Constants.defaultBaseURL else {
      print("❌ [WebViewPresenter] Error: Base URL is nil")
      return
    }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = "/oauth/authorize"
    urlComponents?.queryItems = [
      URLQueryItem(name: "client_id", value: Constants.accessKey),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: Constants.accessScope),
    ]

    guard let url = urlComponents?.url else {
      print("❌ [WebViewPresenter] Error creating URL from components")
      return
    }

    let request = URLRequest(url: url)
    didUpdateProgressValue(0)
    view?.load(request: request)
  }

  func didUpdateProgressValue(_ newValue: Double) {
    let newProgressValue = Float(newValue)
    view?.setProgressValue(newProgressValue)

    let shouldHideProgress = shouldHideProgress(for: newProgressValue)
    view?.setProgressHidden(shouldHideProgress)
  }

  func shouldHideProgress(for value: Float) -> Bool {
    abs(value - 1.0) <= 0.0001
  }
}
