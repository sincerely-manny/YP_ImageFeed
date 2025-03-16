import UIKit

final class ImagesListViewController: UIViewController {
  @IBOutlet private var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
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

extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    19
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

    guard let imageListCell = cell as? ImagesListCell else {
      return UITableViewCell()
    }

    let image = UIImage(named: "\(indexPath.row)")
    imageListCell.configure(with: image)
    if (indexPath.row % 2) == 0 {
      imageListCell.setIsLiked(true)
    } else {
      imageListCell.setIsLiked(false)
    }
    return imageListCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension ImagesListViewController: UITableViewDelegate {

}
