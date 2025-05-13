import UIKit

func transitionToViewController(viewController: UIViewController) {
  guard let window = UIApplication.shared.windows.first else {
    fatalError("No window found")
  }
  viewController.view.frame = window.bounds
  viewController.view.layoutIfNeeded()
  UIView.transition(
    with: window,
    duration: 0.5,
    options: [.transitionCrossDissolve, .beginFromCurrentState],
    animations: {
      UIView.performWithoutAnimation {
        window.rootViewController = viewController
      }
    },
    completion: { _ in
      viewController.view.layoutIfNeeded()
    })
}

func transitionToViewController(controllerIdentifier: String) {
  let storyboard = UIStoryboard(name: "Main", bundle: nil)
  guard
    let viewController = storyboard.instantiateViewController(withIdentifier: controllerIdentifier)
      as? UIViewController
  else {
    let alert = UIAlertController(
      title: "Error",
      message: "Failed to instantiate view controller with identifier \(controllerIdentifier)",
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    // Show alert if possible
    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    return
  }
  transitionToViewController(viewController: viewController)
}
