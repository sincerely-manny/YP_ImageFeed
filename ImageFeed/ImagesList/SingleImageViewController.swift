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

  func configureImageView(with image: Photo) {
    imageView.kf.indicatorType = .activity
    imageView.kf.setImage(
      with: URL(string: image.largeImageURL),
      placeholder: ImageListCellConstants.placeholderImage,
      options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
      ]
    )
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
    //  let minRatio = min(widthRatio, heightRatio) // probably should chnge to min ratio so image will fit to screen

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
  }

  private func setupButtons() {

    let likeButton = UIButton(type: .system)
    likeButton.setImage(UIImage(named: "heart.fill.white.shadow"), for: .normal)
    let shareButton = UIButton(type: .system)
    shareButton.setImage(UIImage(named: "rectangle.and.arrow.up"), for: .normal)

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
      button.tintColor = .ypWhite
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
    dismiss(animated: true)
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
