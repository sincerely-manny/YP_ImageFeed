import UIKit

protocol ImagesListPresenterProtocol {
  var view: ImagesListViewControllerProtocol? { get set }
  var photos: [Photo] { get }

  func viewDidLoad()
  func fetchPhotosNextPage(at indexPath: IndexPath?)
  func toggleLike(for photo: Photo)
  func photoIndex(for id: String) -> Int?
}
