import UIKit

final class AuthViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .ypBlack
    setupLogo()
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
}
