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
  private var estimatedProgressObservation: NSKeyValueObservation?
  var presenter: WebViewPresenterProtocol?

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

    presenter?.viewDidLoad()

    estimatedProgressObservation = webView.observe(
      \.estimatedProgress,
      options: [],
      changeHandler: { [weak self] _, _ in
        guard let self = self else { return }
        presenter?.didUpdateProgressValue(webView.estimatedProgress)
      })

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
  func setProgressHidden(_ isHidden: Bool) {
    progressBar.isHidden = isHidden
  }

  func setProgressValue(_ value: Float) {
    progressBar.setProgress(value, animated: true)
  }
}

// MARK: - WKNavigationDelegate

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
    guard let url = navigationAction.request.url,
      let urlComponents = URLComponents(string: url.absoluteString),
      urlComponents.path == "/oauth/authorize/native"
    else {
      throw WebViewViewControllerError.invalidURL
    }

    guard let items = urlComponents.queryItems,
      let codeItem = items.first(where: { $0.name == "code" }),
      let code = codeItem.value
    else {
      throw WebViewViewControllerError.codeNotFound
    }

    return code
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

extension WebViewViewController: WebViewViewControllerProtocol {
  func load(request: URLRequest) {
    webView.load(request)
  }
}
