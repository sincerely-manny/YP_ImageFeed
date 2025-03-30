import UIKit

final class SingleImageViewController: UIViewController {
  private let imageView = UIImageView()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    setupImageView()
    setupBackButton()
  }

  func configureImageView(with image: UIImage) {
    imageView.image = image
  }

  private func configureView() {
    view.backgroundColor = .ypBlack
  }

  private func setupImageView() {
    imageView.contentMode = .scaleAspectFit
    view.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
  }

  private func setupBackButton() {
    let backButton = UIButton(type: .system)
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16)
    let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)
    backButton.setImage(image, for: .normal)
    backButton.tintColor = .ypWhite
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    view.addSubview(backButton)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalToConstant: 44),
    ])
  }

  @objc private func backButtonTapped() {
    dismiss(animated: true)
  }

  deinit {
    imageView.image = nil
  }
}
