import Foundation

@testable import ImageFeed

final class ImagesListServiceMock: ImagesListServiceProtocol {
  static let didChangeListNotification = Notification.Name(
    rawValue: "ImagesListServiceDidChangeList")
  static let didChangeItemNotification = Notification.Name(
    rawValue: "ImagesListServiceDidChangeItem")

  var photos: [Photo] = []
  var fetchPhotosNextPageCalled = false
  var setLikeCalled = false
  var lastPhotoLiked: Photo?
  var lastLikeState: Bool?

  init() {
    // Initialize with test data
    photos = [
      Photo(
        id: "test_id_1",
        size: CGSize(width: 100, height: 100),
        createdAt: Date(),
        welcomeDescription: "Test photo 1",
        thumbImageURL: "https://example.com/thumb1.jpg",
        largeImageURL: "https://example.com/large1.jpg",
        isLiked: false
      ),
      Photo(
        id: "test_id_2",
        size: CGSize(width: 200, height: 200),
        createdAt: Date(),
        welcomeDescription: "Test photo 2",
        thumbImageURL: "https://example.com/thumb2.jpg",
        largeImageURL: "https://example.com/large2.jpg",
        isLiked: true
      ),
    ]
  }

  func fetchPhotosNextPage() {
    fetchPhotosNextPageCalled = true
  }

  func setLike(_ photo: Photo, to isLiked: Bool, completion: ((Result<Bool, Error>) -> Void)? = nil)
  {
    setLikeCalled = true
    lastPhotoLiked = photo
    lastLikeState = isLiked

    if let index = photos.firstIndex(where: { $0.id == photo.id }) {
      let updatedPhoto = Photo(
        id: photo.id,
        size: photo.size,
        createdAt: photo.createdAt,
        welcomeDescription: photo.welcomeDescription,
        thumbImageURL: photo.thumbImageURL,
        largeImageURL: photo.largeImageURL,
        isLiked: isLiked
      )
      photos[index] = updatedPhoto

      NotificationCenter.default.post(
        name: ImagesListServiceMock.didChangeItemNotification,
        object: nil,
        userInfo: [
          "photo": updatedPhoto,
          "index": index,
        ]
      )
    }

    completion?(.success(isLiked))
  }
}
