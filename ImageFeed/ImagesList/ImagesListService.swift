import Foundation
import ProgressHUD

enum ImagesListServiceConstants {
  static let pageSize = 10
}

final class ImagesListService {
  private(set) var photos: [Photo] = []
  private var likeTasks: [String: URLSessionTask] = [:]
  private var isLoading: Bool = false

  private var lastLoadedPage: Int = 0
  static let didChangeListNotification = Notification.Name(
    rawValue: "ImagesListServiceDidChangeList")
  static let didChangeItemNotification = Notification.Name(
    rawValue: "ImagesListServiceDidChangeItem")

  func fetchPhotosNextPage() {
    assert(Thread.isMainThread)
    guard !isLoading else {
      print("❌ [ImagesListService] Error: Already loading")
      return
    }
    isLoading = true
    let nextPage = lastLoadedPage + 1
    guard
      let request = APIURLRequest.getURLRequest(
        for: "/photos",
        params: [
          "page": String(nextPage),
          "per_page": String(ImagesListServiceConstants.pageSize),
        ]
      )
    else {
      print("❌ [ImagesListService] Error: Unable to create URL request")
      return
    }
    lastLoadedPage = nextPage
    URLSession.shared.query(
      for: request,
      id: "photos-page-\(nextPage))"
    ) { (result: Result<[PhotosResponse], Error>) in
      DispatchQueue.main.async { [weak self] in
        switch result {
        case .success(let photosRes):
          var isChanged = false
          for decodedPhoto in photosRes {
            if self?.photos.contains(where: { $0.id == decodedPhoto.id }) == true {
              continue
            }
            let photo = Photo(photoResponse: decodedPhoto)
            self?.photos.append(photo)
            isChanged = true
          }
          if isChanged {
            NotificationCenter.default.post(
              name: ImagesListService.didChangeListNotification,
              object: nil
            )
          }
        case .failure(let error):
          print("Error fetching photos: \(error)")
        }
        self?.isLoading = false
      }
    }.resume()
  }

  func setLike(
    _ photo: Photo,
    to isLiked: Bool,
    completion: ((Result<Bool, Error>) -> Void)? = nil
  ) {
    assert(Thread.isMainThread)
    UIBlockingProgressHUD.show()
    guard
      let request = APIURLRequest.getURLRequest(
        for: "/photos/\(photo.id)/like",
        method: isLiked ? .post : .delete
      )
    else {
      print("❌ [ImagesListService] Error: Unable to create URL request")
      return
    }
    if let task = likeTasks[photo.id] {
      task.cancel()
    }

    guard let currentPhotoIndex = photos.firstIndex(where: { $0.id == photo.id }) else {
      print("❌ [ImagesListService] Error: Photo not found")
      return
    }
    let currentPhoto = photos[currentPhotoIndex]

    let optimisticPhoto = Photo(
      id: currentPhoto.id,
      size: currentPhoto.size,
      createdAt: currentPhoto.createdAt,
      welcomeDescription: currentPhoto.welcomeDescription,
      thumbImageURL: currentPhoto.thumbImageURL,
      largeImageURL: currentPhoto.largeImageURL,
      isLiked: isLiked
    )

    let task = URLSession.shared.objectTask(for: request) {
      [weak self] (result: Result<LikeResponse, Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let likeResponse):
          if let index = self?.photos.firstIndex(where: { $0.id == photo.id }) {
            let updatedPhoto = Photo(photoResponse: likeResponse.photo)
            self?.photos[index] = updatedPhoto
            self?.postChangeItemNotification(for: updatedPhoto, at: index)
          }
          completion?(.success(likeResponse.photo.likedByUser))
        case .failure(let error):
          print("❌ [ImagesListService] Error setting like: \(error)")
          if let index = self?.photos.firstIndex(where: { $0.id == photo.id }) {
            self?.photos[index] = currentPhoto
            self?.postChangeItemNotification(for: currentPhoto, at: index)
          }
          completion?(.failure(error))
        }
        UIBlockingProgressHUD.dismiss()
      }
    }

    likeTasks[photo.id] = task

    photos[currentPhotoIndex] = optimisticPhoto
    postChangeItemNotification(for: optimisticPhoto, at: currentPhotoIndex)

    task.resume()
  }

  private func postChangeItemNotification(
    for photo: Photo, at index: Int
  ) {
    NotificationCenter.default.post(
      name: ImagesListService.didChangeItemNotification,
      object: nil,
      userInfo: [
        "photo": photo,
        "index": index,
      ]
    )
  }

}
