import UIKit

final class SplashViewController: UIViewController {
  let authService = OAuth2Service.shared
  let activityIndicator = UIActivityIndicatorView(style: .medium)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .ypBlack
    loadLaunchScreenView()
    setupActivityIndicator()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let isLoggedIn = authService.isLoggedIn()

    if isLoggedIn {
      ProfileService.shared.fetchProfileAndTransition(to: "MainTabbarController") { error in
        if let error = error {
          print("Error in fetchProfileAndTransition: \(error)")
          transitionToViewController(controllerIdentifier: "AuthNavController")
        }
      }
    } else {
      transitionToViewController(controllerIdentifier: "AuthNavController")
    }
  }

  private func loadLaunchScreenView() {
    let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
    if let viewController = storyboard.instantiateInitialViewController() {
      addChild(viewController)
      view.addSubview(viewController.view)
      viewController.view.frame = view.bounds
      viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      viewController.didMove(toParent: self)
    }
  }

  private func setupActivityIndicator() {
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.color = .ypWhite
    view.addSubview(activityIndicator)
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    activityIndicator.startAnimating()
  }
}
