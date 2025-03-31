import UIKit

final class SingleImageViewController: UIViewController {
  private let imageView = UIImageView()
  private let scrollView = UIScrollView()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    setupScrollView()
    setupImageView()
    setupGestures()
    setupBackButton()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    updateImageViewFrame()
  }

  deinit {
    imageView.image = nil
  }

  // MARK: - Public methods

  func configureImageView(with image: UIImage) {
    imageView.image = image
  }

  // MARK: - Private methods

  private func configureView() {
    view.backgroundColor = .ypBlack
  }

  private func setupScrollView() {
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
  }

  private func setupImageView() {
    imageView.contentMode = .scaleAspectFit
    imageView.frame.size = view.frame.size
  }

  private func updateImageViewFrame() {
    guard let image = imageView.image else { return }

    let imageWidth = image.size.width
    let imageHeight = image.size.height

    let viewWidth = scrollView.bounds.width
    let viewHeight = scrollView.bounds.height

    let widthRatio = viewWidth / imageWidth
    let heightRatio = viewHeight / imageHeight

    let minRatio = min(widthRatio, heightRatio)

    let scaledWidth = imageWidth * minRatio
    let scaledHeight = imageHeight * minRatio

    let imageFrame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
    imageView.frame = imageFrame
    scrollView.contentSize = imageFrame.size

    self.centerScrollViewContents()
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

  private func setupGestures() {
    // Double tap to zoom
    let doubleTapGesture = UITapGestureRecognizer(
      target: self, action: #selector(handleDoubleTap(_:)))
    doubleTapGesture.numberOfTapsRequired = 2
    view.addGestureRecognizer(doubleTapGesture)
  }

  // MARK: - Gesture Handling

  @objc private func backButtonTapped() {
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
