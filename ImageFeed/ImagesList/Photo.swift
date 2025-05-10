import Foundation

struct Photo {
  let id: String
  let size: CGSize
  let createdAt: Date?
  let welcomeDescription: String?
  let thumbImageURL: String
  let largeImageURL: String
  let isLiked: Bool
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
