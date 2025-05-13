import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
  var presenter: ImagesListPresenterProtocol?
  private var photosCountRef = 0
  private var fullscreenVC: SingleImageViewController?

  private lazy var tableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    tableView.register(
      ImagesListCell.self,
      forCellReuseIdentifier: ImagesListCell.reuseIdentifier
    )

    return tableView
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize presenter if it hasn't been set yet
    if presenter == nil {
      presenter = ImagesListPresenter()
      presenter?.view = self
    }

    photosCountRef = presenter?.photos.count ?? 0
    setupTableView()
    presenter?.viewDidLoad()
  }

  // MARK: - ImagesListViewControllerProtocol
  func updateTableViewAnimated() {
    guard let photosCount = presenter?.photos.count else { return }
    let indexPaths = (photosCountRef..<photosCount).map { IndexPath(row: $0, section: 0) }
    photosCountRef = photosCount

    if indexPaths.isEmpty {
      tableView.reloadData()
    } else {
      tableView.insertRows(at: indexPaths, with: .automatic)
    }
  }

  func showSingleImage(photo: Photo, imageView: UIImageView) {
    fullscreenVC = SingleImageViewController(apiCallDelegate: self)
    guard let fullscreenVC else { return }
    fullscreenVC.configureImageView(with: photo, placeholder: imageView.image)
    fullscreenVC.modalPresentationStyle = .fullScreen

    let transition = CATransition()
    transition.duration = 0.3
    transition.type = .reveal
    transition.subtype = .fromBottom
    view.window?.layer.add(transition, forKey: kCATransition)

    present(fullscreenVC, animated: false)
  }

  func updateCell(at index: Int, with photo: Photo) {
    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
      cell.setIsLiked(photo.isLiked, animated: false)
      cell.photo = photo
    }
  }

  func configureFullscreenVC(with photo: Photo, isLiked: Bool) {
    if let fullscreenVC = self.fullscreenVC {
      fullscreenVC.setIsLiked(isLiked)
      fullscreenVC.photo = photo
    }
  }

  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    tableView.separatorStyle = .none
    tableView.backgroundColor = .ypBlack
    tableView.alwaysBounceHorizontal = false
    tableView.indicatorStyle = .white

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: - Extension DataSource
extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter?.photos.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let imageListCell = tableView.dequeueReusableCell(
        withIdentifier: ImagesListCell.reuseIdentifier,
        for: indexPath
      ) as? ImagesListCell,
      let presenter = presenter,
      indexPath.row < presenter.photos.count
    else {
      return UITableViewCell()
    }

    let photo = presenter.photos[indexPath.row]
    imageListCell.apiCallDelegate = self
    imageListCell.setIsLiked(photo.isLiked)
    imageListCell.configure(with: photo)
    return imageListCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
      let image = cell.photo
    else { return }

    showSingleImage(photo: image, imageView: cell.thumbnailView)
  }

  func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    presenter?.fetchPhotosNextPage(at: indexPath)
  }
}

// MARK: - Extension UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
  // TODO: Implement table view delegate methods
}

extension ImagesListViewController: APICallDelegate {
  func imageListCellDidTapLike(for photo: Photo) {
    presenter?.toggleLike(for: photo)
  }
}
