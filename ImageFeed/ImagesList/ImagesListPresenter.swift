import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
  weak var view: ImagesListViewControllerProtocol?

  private let imagesListService: ImagesListServiceProtocol
  private var photosObserver: NSObjectProtocol?
  private var itemsObserver: NSObjectProtocol?

  var photos: [Photo] {
    return imagesListService.photos
  }

  init(imagesListService: ImagesListServiceProtocol = ImagesListService()) {
    self.imagesListService = imagesListService
  }

  func viewDidLoad() {
    setupObservers()
    imagesListService.fetchPhotosNextPage()
  }

  func fetchPhotosNextPage(at indexPath: IndexPath?) {
    guard let indexPath = indexPath else {
      imagesListService.fetchPhotosNextPage()
      return
    }

    let photosCount = photos.count
    let middleOfLastPageIndex = photosCount - (ImagesListServiceConstants.pageSize / 2)
    if indexPath.row == middleOfLastPageIndex {
      imagesListService.fetchPhotosNextPage()
    }
  }

  func toggleLike(for photo: Photo) {
    imagesListService.setLike(photo, to: !photo.isLiked, completion: nil)
  }

  func photoIndex(for id: String) -> Int? {
    return photos.firstIndex(where: { $0.id == id })
  }

  private func setupObservers() {
    photosObserver = NotificationCenter.default
      .addObserver(
        forName: type(of: imagesListService).didChangeListNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.view?.updateTableViewAnimated()
      }

    itemsObserver = NotificationCenter.default
      .addObserver(
        forName: type(of: imagesListService).didChangeItemNotification,
        object: nil,
        queue: .main
      ) { [weak self] notification in
        guard let self = self,
          let userInfo = notification.userInfo,
          let index = userInfo["index"] as? Int,
          let updatedPhoto = userInfo["photo"] as? Photo
        else { return }

        self.view?.updateCell(at: index, with: updatedPhoto)
        self.view?.configureFullscreenVC(with: updatedPhoto, isLiked: updatedPhoto.isLiked)
      }
  }
}
