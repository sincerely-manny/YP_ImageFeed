import Foundation

struct Photo {
  let id: String
  let size: CGSize
  let createdAt: Date?
  let welcomeDescription: String?
  let thumbImageURL: String
  let largeImageURL: String
  let isLiked: Bool

  private static let dateFormatter = ISO8601DateFormatter()

  init(photoResponse: PhotosResponse) {
    self.id = photoResponse.id
    self.size = CGSize(width: photoResponse.width, height: photoResponse.height)
    self.createdAt = Photo.dateFormatter.date(from: photoResponse.createdAt)
    self.welcomeDescription = photoResponse.description
    self.thumbImageURL = photoResponse.urls.regular
    self.largeImageURL = photoResponse.urls.raw
    self.isLiked = photoResponse.likedByUser
  }

  init(
    id: String,
    size: CGSize,
    createdAt: Date?,
    welcomeDescription: String?,
    thumbImageURL: String,
    largeImageURL: String,
    isLiked: Bool
  ) {
    self.id = id
    self.size = size
    self.createdAt = createdAt
    self.welcomeDescription = welcomeDescription
    self.thumbImageURL = thumbImageURL
    self.largeImageURL = largeImageURL
    self.isLiked = isLiked
  }
}
