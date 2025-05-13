import Kingfisher
import LinkPresentation
import UIKit

final class SingleImageViewController: UIViewController {
  private lazy var imageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private lazy var scrollView = {
    let scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 3.0
    scrollView.addSubview(imageView)
    view.addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
    view.sendSubviewToBack(scrollView)
    return scrollView
  }()

  private var likeButton = UIButton(type: .custom)

  var photo: Photo?
  private var apiCallDelegate: APICallDelegate?

  // MARK: - Init
  init(apiCallDelegate: APICallDelegate? = nil) {
    super.init(nibName: nil, bundle: nil)
    self.apiCallDelegate = apiCallDelegate
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    setupButtons()
    setupGestures()
    setupBackButton()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    updateImageViewFrame()
    scrollToCenter()
  }

  // MARK: - Public methods

  func configureImageView(with image: Photo, placeholder: UIImage?) {
    self.photo = image
    let blurredPlaceholder: UIImage?
    if let placeholderToBlur = placeholder {
      let processor = BlurImageProcessor(blurRadius: 2)
      blurredPlaceholder = processor.process(item: .image(placeholderToBlur), options: .init([]))
    } else {
      blurredPlaceholder = nil
    }

    imageView.kf.indicatorType = .activity
    self.imageView.kf.setImage(
      with: URL(string: image.largeImageURL),
      placeholder: blurredPlaceholder ?? UIImage(named: "card_stub"),
      options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
      ]
    )
    setIsLiked(image.isLiked)
  }

  func setIsLiked(_ isLiked: Bool) {
    let color = isLiked ? UIColor.systemRed : UIColor.white
    likeButton.tintColor = color
    likeButton.imageView?.tintColor = color
  }

  // MARK: - Private methods

  private func configureView() {
    view.backgroundColor = .ypBlack
  }

  private func updateImageViewFrame() {
    guard let image = imageView.image else { return }

    let imageWidth = image.size.width
    let imageHeight = image.size.height

    let viewWidth = scrollView.bounds.width
    let viewHeight = scrollView.bounds.height

    let widthRatio = viewWidth / imageWidth
    let heightRatio = viewHeight / imageHeight

    let maxRatio = max(widthRatio, heightRatio)
    //  let minRatio = min(widthRatio, heightRatio) // probably should change to min ratio so image will fit to screen

    let scaledWidth = imageWidth * maxRatio
    let scaledHeight = imageHeight * maxRatio

    let imageFrame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
    imageView.frame = imageFrame
    scrollView.contentSize = imageFrame.size

    centerScrollViewContents()
  }

  private func centerScrollViewContents() {
    let boundsSize = scrollView.bounds.size
    var contentFrame = imageView.frame

    if contentFrame.size.width < boundsSize.width {
      contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2.0
    } else {
      contentFrame.origin.x = 0
    }

    if contentFrame.size.height < boundsSize.height {
      contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2.0
    } else {
      contentFrame.origin.y = 0
    }

    imageView.frame = contentFrame
  }

  private func scrollToCenter() {
    let offsetX =
      (scrollView.contentSize.width > scrollView.frame.size.width)
      ? (scrollView.contentSize.width - scrollView.frame.size.width) / 2 : 0
    let offsetY =
      (scrollView.contentSize.height > scrollView.frame.size.height)
      ? (scrollView.contentSize.height - scrollView.frame.size.height) / 2 : 0
    scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
  }

  private func setupBackButton() {
    let backButton = UIButton(type: .system)
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16)
    let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)
    backButton.setImage(image, for: .normal)
    backButton.tintColor = .ypWhite
    backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    view.addSubview(backButton)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalToConstant: 44),
    ])
    backButton.accessibilityIdentifier = "nav back button white"
  }

  private func setupButtons() {
    let image = UIImage(named: "heart.fill.white.shadow")?.withRenderingMode(.alwaysTemplate)
    likeButton.setImage(image, for: .normal)
    likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)

    let shareButton = UIButton(type: .system)
    shareButton.setImage(UIImage(named: "rectangle.and.arrow.up"), for: .normal)
    shareButton.tintColor = .ypWhite

    shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)

    let container = UIStackView(arrangedSubviews: [
      UIView(), likeButton, UIView(), shareButton, UIView(),
    ])

    container.axis = .horizontal
    container.alignment = .center
    container.distribution = .equalSpacing
    container.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(container)
    NSLayoutConstraint.activate([
      container.bottomAnchor.constraint(
        equalTo: view.layoutMarginsGuide.bottomAnchor,
        constant: -16
      ),
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      container.heightAnchor.constraint(equalToConstant: 50),
    ])

    [shareButton, likeButton].forEach { button in
      button.backgroundColor = .ypBlack
      button.translatesAutoresizingMaskIntoConstraints = false
      button.layer.cornerRadius = 25
      button.clipsToBounds = true

      NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: 50),
        button.heightAnchor.constraint(equalToConstant: 50),
      ])
    }
  }

  // MARK: - Gesture Handling

  private func setupGestures() {
    let doubleTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(handleDoubleTap(_:))
    )
    doubleTapGesture.numberOfTapsRequired = 2
    view.addGestureRecognizer(doubleTapGesture)
  }

  @objc private func didTapBackButton() {
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = .moveIn
    transition.subtype = .fromTop
    view.window?.layer.add(transition, forKey: kCATransition)
    dismiss(animated: false)
  }

  @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
    if scrollView.zoomScale > scrollView.minimumZoomScale {
      scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    } else {
      let point = gesture.location(in: imageView)
      let zoomRect = CGRect(
        x: point.x - (scrollView.bounds.width / 4),
        y: point.y - (scrollView.bounds.height / 4),
        width: scrollView.bounds.width / 2,
        height: scrollView.bounds.height / 2
      )
      scrollView.zoom(to: zoomRect, animated: true)
    }
  }

  @objc private func didTapShareButton() {
    guard let image = imageView.image else { return }
    let activityViewController = UIActivityViewController(
      activityItems: [image, self as UIActivityItemSource],
      applicationActivities: nil
    )
    present(activityViewController, animated: true)
  }

  @objc private func didTapLikeButton() {
    guard let photo = photo else { return }
    apiCallDelegate?.imageListCellDidTapLike(for: photo)
  }

}

// MARK: - ScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    centerScrollViewContents()
  }
}

extension SingleImageViewController: UIActivityItemSource {
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController)
    -> Any
  {
    imageView.image ?? UIImage()
  }

  func activityViewController(
    _ activityViewController: UIActivityViewController,
    itemForActivityType activityType: UIActivity.ActivityType?
  ) -> Any? {
    return nil
  }

  func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController)
    -> LPLinkMetadata?
  {
    let image = imageView.image ?? UIImage()
    let imageProvider = NSItemProvider(object: image)
    let metadata = LPLinkMetadata()
    metadata.imageProvider = imageProvider
    return metadata
  }
}
