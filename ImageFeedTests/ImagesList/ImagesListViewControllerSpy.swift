import UIKit

@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
  var presenter: ImagesListPresenterProtocol?

  var updateTableViewAnimatedCalled = false
  var showSingleImageCalled = false
  var updateCellCalled = false
  var configureFullscreenVCCalled = false

  var lastPhotoForSingleImage: Photo?
  var lastImageViewForSingleImage: UIImageView?
  var lastIndexForUpdateCell: Int?
  var lastPhotoForUpdateCell: Photo?
  var lastPhotoForFullscreenVC: Photo?
  var lastIsLikedForFullscreenVC: Bool?

  func updateTableViewAnimated() {
    updateTableViewAnimatedCalled = true
  }

  func showSingleImage(photo: Photo, imageView: UIImageView) {
    showSingleImageCalled = true
    lastPhotoForSingleImage = photo
    lastImageViewForSingleImage = imageView
  }

  func updateCell(at index: Int, with photo: Photo) {
    updateCellCalled = true
    lastIndexForUpdateCell = index
    lastPhotoForUpdateCell = photo
  }

  func configureFullscreenVC(with photo: Photo, isLiked: Bool) {
    configureFullscreenVCCalled = true
    lastPhotoForFullscreenVC = photo
    lastIsLikedForFullscreenVC = isLiked
  }
}
