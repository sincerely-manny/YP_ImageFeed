import UIKit

final class ImagesListViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet private var tableView: UITableView!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
  }

  // MARK: - Private Methods
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    tableView.separatorStyle = .none
    tableView.layer.backgroundColor = .none
    tableView.alwaysBounceHorizontal = false
  }
}

// MARK: - Extension DataSource
extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    19
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

    let image = UIImage(named: "\(indexPath.row)")
    imageListCell.configure(with: image)
    imageListCell.setIsLiked(indexPath.row % 2 == 0)
    return imageListCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // TODO: Implement image selection logic
    print("Image selected at index \(indexPath.row)")
  }
}

// MARK: - Extension UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
  // TODO: Implement table view delegate methods
}
