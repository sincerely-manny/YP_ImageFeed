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
