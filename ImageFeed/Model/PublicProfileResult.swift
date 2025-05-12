struct PublicProfileResult: Codable {
  let id: String
  let username: String
  let name: String
  let firstName: String?
  let lastName: String?
  let bio: String?
  let profileImage: ProfileImage?
}
