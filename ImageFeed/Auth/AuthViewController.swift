import UIKit

final class AuthViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .ypBlack
    setupLogo()
    setupLoginButton()
    configureBackButton()
    setNeedsStatusBarAppearanceUpdate()
  }

  private func setupLogo() {
    let logoImageView = UIImageView(image: UIImage(named: "auth_screen_logo"))
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    logoImageView.contentMode = .scaleAspectFit
    view.addSubview(logoImageView)
    NSLayoutConstraint.activate([
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.topAnchor.constraint(
        equalTo: view.topAnchor, constant: view.bounds.height / 2.9),
      logoImageView.widthAnchor.constraint(equalToConstant: 60),
      logoImageView.heightAnchor.constraint(equalToConstant: 60),
    ])
  }

  private func setupLoginButton() {
    let loginButton = UIButton(type: .system)

    loginButton.setAttributedTitle(
      NSAttributedString(
        string: "Войти",
        attributes: [
          .font: UIFont.systemFont(ofSize: 17, weight: .bold),
          .foregroundColor: UIColor.ypBlack,
        ]), for: .normal)
    loginButton.backgroundColor = .ypWhite
    loginButton.layer.cornerRadius = 16
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(loginButton)
    NSLayoutConstraint.activate([
      loginButton.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
      loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      loginButton.heightAnchor.constraint(equalToConstant: 50),
    ])

    loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
  }

  private func configureBackButton() {
    navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
    navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(
      named: "nav_back_button")
    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "", style: .plain, target: nil, action: nil)
    navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
  }

  @objc private func loginButtonTapped() {
    let vc = WebViewViewController(delegate: self)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension AuthViewController: WebViewViewControllerDelegate {
  func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
    UIBlockingProgressHUD.show()
    OAuth2Service.shared.getAccessToken(code: code) { result in
      UIBlockingProgressHUD.dismiss()
      switch result {
      case .success(_):
        transitionToViewController(controllerIdentifier: "MainTabbarController")
      case .failure(let error):
        //TODO: Handle error
        print("Error fetching access token: \(error)")
      }
    }
  }

  func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
    self.navigationController?.popViewController(animated: true)
  }
}
