import UIKit

@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
  var view: ImagesListViewControllerProtocol?
  var photos: [Photo] = []

  var viewDidLoadCalled = false
  var fetchPhotosNextPageCalled = false
  var toggleLikeCalled = false
  var lastPhotoForToggleLike: Photo?
  var lastIndexPathForFetchPhotos: IndexPath?

  func viewDidLoad() {
    viewDidLoadCalled = true
  }

  func fetchPhotosNextPage(at indexPath: IndexPath?) {
    fetchPhotosNextPageCalled = true
    lastIndexPathForFetchPhotos = indexPath
  }

  func toggleLike(for photo: Photo) {
    toggleLikeCalled = true
    lastPhotoForToggleLike = photo
  }

  func photoIndex(for id: String) -> Int? {
    return photos.firstIndex(where: { $0.id == id })
  }
}
