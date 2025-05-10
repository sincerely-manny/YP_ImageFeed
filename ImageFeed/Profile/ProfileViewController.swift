import UIKit

final class ProfileViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    let header = setupHeader()
    setupFavorites(topAnchor: header.bottomAnchor)
  }

  // MARK: - Setup subviews
  private func setupView() {
    view.layer.backgroundColor = UIColor.ypBlack.cgColor
    view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }

  // MARK: - Header
  private func setupHeader() -> UIView {
    let header = UIView()

    header.translatesAutoresizingMaskIntoConstraints = false
    header.layoutMargins = .zero
    view.addSubview(header)

    NSLayoutConstraint.activate([
      header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
      header.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      header.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
    ])

    let avatar = setupAvatar(parentView: header)
    setupExitButton(parentView: header, centerYAnchor: avatar.centerYAnchor)
    let nameLabel = setupName(parentView: header, topAnchor: avatar.bottomAnchor)
    let tagLabel = setupTag(parentView: header, topAnchor: nameLabel.bottomAnchor)
    setupStatus(parentView: header, topAnchor: tagLabel.bottomAnchor)

    return header
  }

  // MARK: - Avatar
  private func setupAvatar(parentView view: UIView) -> UIImageView {
    let avatar = UIImageView()

    avatar.contentMode = .scaleAspectFill
    avatar.layer.cornerRadius = 35
    avatar.layer.masksToBounds = true
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.image = UIImage(named: "0")
    view.addSubview(avatar)

    NSLayoutConstraint.activate([
      avatar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      avatar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      avatar.widthAnchor.constraint(equalToConstant: 70),
      avatar.heightAnchor.constraint(equalToConstant: 70),
    ])
    return avatar
  }

  // MARK: - Exit Button
  private func setupExitButton(
    parentView view: UIView, centerYAnchor: NSLayoutYAxisAnchor
  ) {
    let exitButton = UIButton()

    let image = UIImage(named: "rectangle.and.arrow.in.red")
    exitButton.setImage(image, for: .normal)
    exitButton.imageView?.contentMode = .scaleAspectFit
    exitButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 8)
    exitButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(exitButton)

    NSLayoutConstraint.activate([
      exitButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      exitButton.widthAnchor.constraint(equalToConstant: 44),
      exitButton.heightAnchor.constraint(equalToConstant: 44),
      exitButton.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])

    exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
  }

  @objc private func exitButtonTapped() {
    OAuth2Service.shared.logout()
  }

  // MARK: - Name
  private func setupName(parentView view: UIView, topAnchor: NSLayoutYAxisAnchor) -> UILabel {
    let label = UILabel()

    label.textColor = .ypWhite
    let letterSpacing: CGFloat = -0.08
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 0.78
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 23, weight: .bold),
      .kern: letterSpacing,
      .foregroundColor: UIColor.ypWhite,
      .paragraphStyle: paragraphStyle,
    ]
    label.attributedText = NSAttributedString(string: "Екатерина Новикова", attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
    ])
    return label
  }

  // MARK: - Tag
  private func setupTag(parentView view: UIView, topAnchor: NSLayoutYAxisAnchor) -> UILabel {
    let label = UILabel()

    label.baselineAdjustment = .alignCenters
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 13, weight: .regular),
      .foregroundColor: UIColor.ypGray,
    ]
    label.attributedText = NSAttributedString(string: "@ekaterina_nov", attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.heightAnchor.constraint(equalToConstant: 18),
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
    ])
    return label
  }

  // MARK: - Status
  private func setupStatus(parentView view: UIView, topAnchor: NSLayoutYAxisAnchor) {
    let label = UILabel()

    label.textColor = .ypWhite
    label.baselineAdjustment = .alignCenters
    label.numberOfLines = 1
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 13, weight: .regular),
      .foregroundColor: UIColor.ypWhite,
    ]
    label.attributedText = NSAttributedString(string: "Hello, world!", attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.heightAnchor.constraint(equalToConstant: 18),
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
    ])
  }

  // MARK: - Favorites
  private func setupFavorites(topAnchor: NSLayoutYAxisAnchor) {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.layoutMargins = .zero
    view.addSubview(container)

    NSLayoutConstraint.activate([
      container.topAnchor.constraint(equalTo: topAnchor, constant: 24),
      container.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
    ])

    let label = UILabel()
    label.textColor = .ypWhite

    label.textColor = .ypWhite
    let letterSpacing: CGFloat = 0.3
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 0.78
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 23, weight: .bold),
      .kern: letterSpacing,
      .foregroundColor: UIColor.ypWhite,
      .paragraphStyle: paragraphStyle,
    ]
    label.attributedText = NSAttributedString(string: "Избранное", attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(label)

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
      label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
    ])
  }

}
