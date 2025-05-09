import UIKit
@preconcurrency import WebKit

enum WebViewViewControllerError: Error {
  case invalidURL
  case codeNotFound
}

final class WebViewViewController: UIViewController {
  private let webView = WKWebView()
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let progressBar = UIProgressView(progressViewStyle: .default)

  private var delegate: WebViewViewControllerDelegate

  init(delegate: WebViewViewControllerDelegate) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .ypBlack
    setNeedsStatusBarAppearanceUpdate()
    configureNavBar()
    setupWebView()
    setupActivityIndicator()
    setupProgressBar()

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
    ]
    if let url = urlComponents?.url {
      let request = URLRequest(url: url)
      webView.load(request)
    } else {
      print("❌ Error creating URL from components")
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    webView.addObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress),
      options: .new,
      context: nil)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    webView.removeObserver(
      self,
      forKeyPath: #keyPath(WKWebView.estimatedProgress))
  }

  private func setupWebView() {
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.navigationDelegate = self
    view.addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func configureNavBar() {
    if let navigationBar = navigationController?.navigationBar {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      appearance.backgroundColor = .clear
      appearance.shadowColor = .clear

      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
    }
  }

  private func setupActivityIndicator() {
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.color = .ypBlack
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    activityIndicator.startAnimating()
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }

  private func setupProgressBar() {
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    progressBar.progressTintColor = .ypBlack
    progressBar.trackTintColor = .clear
    view.addSubview(progressBar)
    NSLayoutConstraint.activate([
      progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

}

extension WebViewViewController {
  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if keyPath == #keyPath(WKWebView.estimatedProgress) {
      updateProgress()
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  private func updateProgress() {
    progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
    progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
  }
}

extension WebViewViewController: WKNavigationDelegate {
  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    var code: String

    do {
      code = try grabOAuthCode(from: navigationAction)
    } catch {
      print("❌ Error: \(error)")
      decisionHandler(.allow)
      return
    }

    delegate.webViewViewController(self, didAuthenticateWithCode: code)
    decisionHandler(.cancel)
  }

  private func grabOAuthCode(from navigationAction: WKNavigationAction) throws -> String {
    if let url = navigationAction.request.url,
      let urlComponents = URLComponents(string: url.absoluteString),
      urlComponents.path == "/oauth/authorize/native",
      let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == "code" })
    {
      guard let code = codeItem.value else {
        throw WebViewViewControllerError.codeNotFound
      }
      return code
    } else {
      throw WebViewViewControllerError.invalidURL
    }
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
    activityIndicator.startAnimating()
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
    activityIndicator.stopAnimating()
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
    activityIndicator.stopAnimating()
  }

  func webView(
    _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation,
    withError error: Error
  ) {
    activityIndicator.stopAnimating()
  }
}
