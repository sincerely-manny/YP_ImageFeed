import UIKit

final class SplashViewController: UIViewController {
  let authService = OAuth2Service.shared

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .ypBlack
    loadLaunchScreenView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    transitionToViewController(
      controllerIdentifier: authService.isLoggedIn() ? "MainTabbarController" : "AuthNavController")
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
}
