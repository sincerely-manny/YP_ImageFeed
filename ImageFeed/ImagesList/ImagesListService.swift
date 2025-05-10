import Foundation

enum ImagesListServiceConstants {
  static let pageSize = 10
}

final class ImagesListService {
  private(set) var photos: [Photo] = []

  private var lastLoadedPage: Int = 0
  static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

  func fetchPhotosNextPage() {
    assert(Thread.isMainThread)
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
            let photo = Photo(
              id: decodedPhoto.id,
              size: CGSize(
                width: decodedPhoto.width,
                height: decodedPhoto.height
              ),
              createdAt: DateFormatter().date(from: decodedPhoto.createdAt),
              welcomeDescription: decodedPhoto.description,
              thumbImageURL: decodedPhoto.urls.thumb,
              largeImageURL: decodedPhoto.urls.full,
              isLiked: decodedPhoto.likedByUser
            )
            self?.photos.append(photo)
            isChanged = true
          }
          if isChanged {
            NotificationCenter.default.post(
              name: ImagesListService.didChangeNotification,
              object: nil
            )
          }
        case .failure(let error):
          print("Error fetching photos: \(error)")
        }
      }
    }.resume()
  }
}
