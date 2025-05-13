struct LikeResponse: Decodable {
  let photo: PhotosResponse
  let user: PublicProfileResult
}
