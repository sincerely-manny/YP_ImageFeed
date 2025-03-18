import UIKit

// MARK: - Style
struct ImageListCellStyle {
  let gap: CGFloat
  let paddingHorizontal: CGFloat
}

final class ImagesListCell: UITableViewCell {
  static let reuseIdentifier = "ImagesListCell"

  // MARK: - Private Properties
  private let style = ImageListCellStyle(gap: 8, paddingHorizontal: 16)

  private let thumbnailView = UIImageView()
  private let heartButton = UIButton()
  private let labelContainerView = GradientView()
  private let labelView = UILabel()

  private var aspectRatioConstraint: NSLayoutConstraint?
  private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }()

  private var isLiked: Bool = false

  // MARK: - Lifecycle
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layer.backgroundColor = UIColor.ypRed.cgColor

    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailView.image = nil
    aspectRatioConstraint?.isActive = false
  }

  // MARK: - UI Updates
  func configure(with image: UIImage?, date: Date = Date()) {
    thumbnailView.image = image
    let text = dateFormatter.string(from: date)
    setLabelText(text)
    if let image = image {
      let aspectRatio = image.size.height / image.size.width
      aspectRatioConstraint?.isActive = false
      aspectRatioConstraint = thumbnailView.heightAnchor.constraint(
        equalTo: thumbnailView.widthAnchor, multiplier: aspectRatio)
      aspectRatioConstraint?.isActive = true
    }

    setNeedsLayout()
    layoutIfNeeded()
  }

  func setIsLiked(_ isLiked: Bool, animated: Bool = false) {
    self.isLiked = isLiked
    switchHeartButtonState(animated: animated)
  }

  // MARK: - Private Methods
  private func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    preservesSuperviewLayoutMargins = false
    contentView.preservesSuperviewLayoutMargins = false
    contentView.layoutMargins = UIEdgeInsets(
      top: style.gap / 2, left: style.paddingHorizontal, bottom: style.gap / 2,
      right: style.paddingHorizontal)
    setupImageView()
    setupButton()
    setupLabelContainer()
  }

  private func setupImageView() {
    thumbnailView.contentMode = .scaleAspectFill
    thumbnailView.translatesAutoresizingMaskIntoConstraints = false
    thumbnailView.layer.cornerRadius = 16
    thumbnailView.layer.masksToBounds = true
    contentView.addSubview(thumbnailView)

    NSLayoutConstraint.activate([
      thumbnailView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      thumbnailView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      thumbnailView.trailingAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      thumbnailView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
    ])
  }

  private func setupButton() {
    heartButton.translatesAutoresizingMaskIntoConstraints = false
    heartButton.backgroundColor = .clear
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20)
    let image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(
      .ypWhite)
    heartButton.setImage(image, for: .normal)
    heartButton.tintColor = .clear
    heartButton.layer.opacity = 0.5

    if let imageView = heartButton.imageView {
      imageView.layer.shadowColor = UIColor.ypBlack.cgColor
      imageView.layer.shadowRadius = 4
      imageView.layer.shadowOpacity = 0.2
      imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
      imageView.clipsToBounds = false
      imageView.tintColor = .ypWhite
    }

    heartButton.transform = CGAffineTransform(scaleX: 1.075, y: 1)

    heartButton.addTarget(self, action: #selector(didTapHeartButton), for: .touchUpInside)

    contentView.addSubview(heartButton)

    NSLayoutConstraint.activate([
      heartButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      heartButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      heartButton.widthAnchor.constraint(equalToConstant: 44),
      heartButton.heightAnchor.constraint(equalToConstant: 44),
    ])
  }

  @objc func didTapHeartButton() {
    feedbackGenerator.prepare()
    feedbackGenerator.impactOccurred()
    setIsLiked(isLiked ? false : true, animated: true)
  }

  private func switchHeartButtonState(animated: Bool) {
    if isLiked {
      self.heartButton.layer.opacity = 1
      self.heartButton.imageView?.tintColor = .ypRed
    } else {
      self.heartButton.layer.opacity = 0.5
      self.heartButton.imageView?.tintColor = .ypWhite
    }

    if animated, #available(iOS 17.0, *) {
      heartButton.imageView?.addSymbolEffect(.bounce)
    }
  }

  private func setupLabelContainer() {
    labelContainerView.translatesAutoresizingMaskIntoConstraints = false
    labelContainerView.layer.cornerRadius = 16
    labelContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    labelContainerView.layer.masksToBounds = true

    contentView.addSubview(labelContainerView)

    labelContainerView.setupGradient(
      colors: [
        UIColor.black.withAlphaComponent(0),
        UIColor.black.withAlphaComponent(0.5),
      ],
      locations: [0, 0.5]
    )

    contentView.addSubview(labelContainerView)

    NSLayoutConstraint.activate([
      labelContainerView.leadingAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      labelContainerView.trailingAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      labelContainerView.bottomAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      labelContainerView.heightAnchor.constraint(equalToConstant: 30),
    ])

    labelView.textColor = .ypWhite
    labelView.font = .systemFont(ofSize: 13, weight: .regular)
    labelView.numberOfLines = 1
    labelView.translatesAutoresizingMaskIntoConstraints = false

    labelContainerView.addSubview(labelView)
    NSLayoutConstraint.activate([
      labelView.leadingAnchor.constraint(equalTo: labelContainerView.leadingAnchor, constant: 8),
      labelView.trailingAnchor.constraint(equalTo: labelContainerView.trailingAnchor, constant: -8),
      labelView.bottomAnchor.constraint(equalTo: labelContainerView.bottomAnchor, constant: -8),
    ])
  }

  private func setLabelText(_ text: String?) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 1.4
    let letterSpacing: CGFloat = -0.08
    let attributes: [NSAttributedString.Key: Any] = [
      .paragraphStyle: paragraphStyle,
      .kern: letterSpacing,
      .foregroundColor: UIColor.ypWhite,
    ]

    labelView.attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
  }
}
