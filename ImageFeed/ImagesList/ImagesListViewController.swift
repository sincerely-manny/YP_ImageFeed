import UIKit

final class ImagesListViewController: UIViewController {
  private let imagesListService = ImagesListService()
  private var photosObserver: NSObjectProtocol?
  private var itemsObserver: NSObjectProtocol?
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
    photosCountRef = imagesListService.photos.count
    setupTableView()

    photosObserver = NotificationCenter.default
      .addObserver(
        forName: ImagesListService.didChangeListNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.updateTableViewAnimated()
      }

    itemsObserver = NotificationCenter.default
      .addObserver(
        forName: ImagesListService.didChangeItemNotification,
        object: nil,
        queue: .main
      ) { [weak self] notification in
        guard let self = self,
          let userInfo = notification.userInfo,
          let index = userInfo["index"] as? Int,
          let updatedPhoto = userInfo["photo"] as? Photo
        else { return }
        //self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0))
          as? ImagesListCell
        {
          cell.setIsLiked(updatedPhoto.isLiked, animated: true)
          cell.photo = updatedPhoto
        }
        if let fullscreenVC = self.fullscreenVC {
          fullscreenVC.setIsLiked(updatedPhoto.isLiked)
          fullscreenVC.photo = updatedPhoto
        }
      }

    imagesListService.fetchPhotosNextPage()
  }

  private func updateTableViewAnimated() {
    let newPhotosCount = imagesListService.photos.count
    let indexPaths = (photosCountRef..<newPhotosCount).map { IndexPath(row: $0, section: 0) }
    photosCountRef = newPhotosCount

    if indexPaths.isEmpty {
      tableView.reloadData()
    } else {
      tableView.insertRows(at: indexPaths, with: .automatic)
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
    imagesListService.photos.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let imageListCell = tableView.dequeueReusableCell(
        withIdentifier: ImagesListCell.reuseIdentifier,
        for: indexPath
      ) as? ImagesListCell
    else {
      return UITableViewCell()
    }

    let photo = imagesListService.photos[indexPath.row]
    imageListCell.apiCallDelegate = self
    imageListCell.setIsLiked(photo.isLiked)
    imageListCell.configure(with: photo)
    return imageListCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
      let image = cell.photo
    else { return }
    let fullscreenVC = SingleImageViewController(apiCallDelegate: self)
    fullscreenVC.configureImageView(with: image, placeholder: cell.thumbnailView.image)
    fullscreenVC.modalPresentationStyle = .fullScreen

    let transition = CATransition()
    transition.duration = 0.3
    transition.type = .reveal
    transition.subtype = .fromBottom
    view.window?.layer.add(transition, forKey: kCATransition)

    present(fullscreenVC, animated: false)
  }

  func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    let photosCount = imagesListService.photos.count
    let middleOfLastPageIndex = photosCount - (ImagesListServiceConstants.pageSize / 2)
    if indexPath.row == middleOfLastPageIndex {
      imagesListService.fetchPhotosNextPage()
    }
  }
}

// MARK: - Extension UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
  // TODO: Implement table view delegate methods
}

extension ImagesListViewController: APICallDelegate {
  func imageListCellDidTapLike(for photo: Photo) {
    imagesListService.setLike(photo, to: !photo.isLiked)
  }
}
