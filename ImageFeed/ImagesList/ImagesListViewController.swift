import UIKit

final class ImagesListViewController: UIViewController {
  private let imagesListService = ImagesListService()
  private var photosObserver: NSObjectProtocol?

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
    setupTableView()

    photosObserver = NotificationCenter.default
      .addObserver(
        forName: ImagesListService.didChangeNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        guard let self = self else { return }
        self.tableView.reloadData()
      }

    imagesListService.fetchPhotosNextPage()
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

    //let image = UIImage(named: "\(indexPath.row)")
    //imageListCell.configure(with: image)
    //
    let photo = imagesListService.photos[indexPath.row]
    imageListCell.setIsLiked(photo.isLiked)
    imageListCell.configure(with: photo)
    return imageListCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
      let image = cell.thumbnailView.image as UIImage?
    else { return }
    let fullscreenVC = SingleImageViewController()
    fullscreenVC.configureImageView(with: image)
    fullscreenVC.modalPresentationStyle = .fullScreen
    fullscreenVC.modalTransitionStyle = .crossDissolve
    present(fullscreenVC, animated: true)
  }

  func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    if indexPath.row == ImagesListServiceConstants.pageSize / 2 {
      imagesListService.fetchPhotosNextPage()
    }
  }
}

// MARK: - Extension UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
  // TODO: Implement table view delegate methods
}
