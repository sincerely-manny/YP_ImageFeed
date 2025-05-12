import Kingfisher
import UIKit

enum ProfileViewControllerConstants {
  static let avatarSize: CGFloat = 70
  static let avatarCornerRadius: CGFloat = 35
  static let placeholderImage = UIImage(named: "userpic_stub")
}

final class ProfileViewController: UIViewController {
  private let profileService = ProfileService.shared
  private var header = UIView()
  private var avatar = UIImageView()
  private var nameLabel = UILabel()
  private var tagLabel = UILabel()
  private var bioLabel = UILabel()

  private var user: Profile? {
    didSet {
      guard let user = user else { return }
      setupName(parentView: header, topAnchor: avatar.bottomAnchor, text: user.name)
      setupTag(
        parentView: header, topAnchor: nameLabel.bottomAnchor, text: user.loginName)
      setupBio(
        parentView: header, topAnchor: tagLabel.bottomAnchor, text: user.bio ?? " ")
    }
  }

  private var profileImageServiceObserver: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupHeader()
    setupFavorites(topAnchor: header.bottomAnchor)
    user = profileService.profile

    profileImageServiceObserver = NotificationCenter.default
      .addObserver(
        forName: profileService.didChangeProfileImageNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        guard let self = self else { return }
        self.updateAvatar()
      }

    updateAvatar()

  }

  private func updateAvatar() {
    guard let profile = profileService.profile else { return }
    if let url = profile.avatar {
      avatar.kf.setImage(
        with: url,
        placeholder: ProfileViewControllerConstants.placeholderImage,
        options: [
          .transition(.fade(0.2)),
          .cacheOriginalImage,
        ]
      )
    } else {
      avatar.image = ProfileViewControllerConstants.placeholderImage
    }
  }

  // MARK: - Setup subviews
  private func setupView() {
    view.layer.backgroundColor = UIColor.ypBlack.cgColor
    view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }

  // MARK: - Header
  private func setupHeader() {
    header.translatesAutoresizingMaskIntoConstraints = false
    header.layoutMargins = .zero
    view.addSubview(header)

    NSLayoutConstraint.activate([
      header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
      header.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      header.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
    ])

    let avatar = setupAvatar(parentView: header)
    setupName(parentView: header, topAnchor: avatar.bottomAnchor, text: " ")
    setupTag(
      parentView: header, topAnchor: nameLabel.bottomAnchor, text: " ")
    setupBio(
      parentView: header, topAnchor: tagLabel.bottomAnchor, text: " ")
    setupExitButton(parentView: header, centerYAnchor: avatar.centerYAnchor)

  }

  // MARK: - Avatar
  private func setupAvatar(parentView view: UIView) -> UIImageView {
    avatar = UIImageView()

    avatar.contentMode = .scaleAspectFill
    avatar.layer.cornerRadius = ProfileViewControllerConstants.avatarCornerRadius
    avatar.layer.masksToBounds = true
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.image = ProfileViewControllerConstants.placeholderImage
    view.addSubview(avatar)

    NSLayoutConstraint.activate([
      avatar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      avatar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      avatar.widthAnchor.constraint(equalToConstant: ProfileViewControllerConstants.avatarSize),
      avatar.heightAnchor.constraint(equalToConstant: ProfileViewControllerConstants.avatarSize),
    ])

    avatar.kf.indicatorType = .activity
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
    let alert = UIAlertController(
      title: "Пока, пока!",
      message: "Уверены что хотите выйти?",
      preferredStyle: .alert
    )
    let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
    let okAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
      guard let self = self else { return }
      OAuth2Service.shared.logout()
      self.dismiss(animated: true)
    }
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true)
  }

  // MARK: - Name
  private func setupName(parentView view: UIView, topAnchor: NSLayoutYAxisAnchor, text: String) {
    let label = nameLabel

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
    label.attributedText = NSAttributedString(string: text, attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
    ])
  }

  // MARK: - Tag
  private func setupTag(parentView view: UIView, topAnchor: NSLayoutYAxisAnchor, text: String) {
    let label = tagLabel

    label.baselineAdjustment = .alignCenters
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 13, weight: .regular),
      .foregroundColor: UIColor.ypGray,
    ]
    label.attributedText = NSAttributedString(string: text, attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.heightAnchor.constraint(equalToConstant: 18),
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
    ])
  }

  // MARK: - Bio
  private func setupBio(parentView view: UIView, topAnchor: NSLayoutYAxisAnchor, text: String) {
    let label = bioLabel

    label.textColor = .ypWhite
    label.baselineAdjustment = .alignCenters
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.text = text

    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 13, weight: .regular),
      .foregroundColor: UIColor.ypWhite,
    ]
    label.attributedText = NSAttributedString(string: text, attributes: attributes)

    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.heightAnchor.constraint(equalToConstant: 18),
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
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
