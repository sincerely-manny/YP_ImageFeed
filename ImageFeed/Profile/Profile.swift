import Foundation

struct Profile {
  let username: String
  let name: String
  let loginName: String
  let bio: String?
  var avatar: URL?
}

struct ProfileResult: Codable {
  let id: String
  let username: String
  let firstName: String?
  let lastName: String?
  let bio: String?
  let email: String?
}

struct PublicProfileResult: Codable {
  let id: String
  let username: String
  let name: String
  let firstName: String?
  let lastName: String?
  let bio: String?
  let profileImage: ProfileImage?
}

struct ProfileImage: Codable {
  let small: String
  let medium: String
  let large: String
}
