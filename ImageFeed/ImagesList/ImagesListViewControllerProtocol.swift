import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
  var presenter: ImagesListPresenterProtocol? { get set }
  func updateTableViewAnimated()
  func showSingleImage(photo: Photo, imageView: UIImageView)
  func updateCell(at index: Int, with photo: Photo)
  func configureFullscreenVC(with photo: Photo, isLiked: Bool)
}
