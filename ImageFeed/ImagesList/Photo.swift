import Foundation

//struct Photo {
//  let id: String
//  let size: CGSize
//  let createdAt: Date?
//  let welcomeDescription: String?
//  let thumbImageURL: String
//  let largeImageURL: String
//  let isLiked: Bool
//}

class Photo {
  let id: String
  let size: CGSize
  let createdAt: Date?
  let welcomeDescription: String?
  let thumbImageURL: String
  let largeImageURL: String
  let isLiked: Bool

  init(photoResponse: PhotosResponse) {
    self.id = photoResponse.id
    self.size = CGSize(width: photoResponse.width, height: photoResponse.height)
    self.createdAt = DateFormatter().date(from: photoResponse.createdAt)
    self.welcomeDescription = photoResponse.description
    self.thumbImageURL = photoResponse.urls.thumb
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

struct PhotosResponse: Decodable {
  let id: String
  let createdAt: String
  let updatedAt: String
  let width: Int
  let height: Int
  let color: String
  let blurHash: String
  let likes: Int
  let likedByUser: Bool
  let description: String?
  let user: PublicProfileResult
  let urls: PhotoURLs
}

struct PhotoURLs: Decodable {
  let raw: String
  let full: String
  let regular: String
  let small: String
  let thumb: String
}

struct LikeResponse: Decodable {
  let photo: PhotosResponse
  let user: PublicProfileResult
}
