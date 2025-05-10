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
  let updatedAt: String
  let username: String
  let firstName: String?
  let lastName: String?
  let twitterUsername: String?
  let portfolioUrl: String?
  let bio: String?
  let location: String?
  let totalLikes: Int
  let totalPhotos: Int
  let totalCollections: Int
  let downloads: Int?
  let uploadsRemaining: Int
  let instagramUsername: String?
  let email: String?
  let links: ProfileLinks
}

struct ProfileLinks: Codable {
  let selfLink: String
  let html: String
  let photos: String
  let likes: String
  let portfolio: String

  enum CodingKeys: String, CodingKey {
    case selfLink = "self"
    case html, photos, likes, portfolio
  }
}

struct PublicProfileResult: Codable {
  let id: String
  let updatedAt: String
  let username: String
  let name: String
  let firstName: String?
  let lastName: String?
  let instagramUsername: String?
  let twitterUsername: String?
  let portfolioUrl: String?
  let bio: String?
  let location: String?
  let totalLikes: Int
  let totalPhotos: Int
  let totalCollections: Int
  let downloads: Int?
  let social: SocialLinks
  let profileImage: ProfileImage?
  let badge: Badge?
}

struct ProfileImage: Codable {
  let small: String
  let medium: String
  let large: String
}

struct SocialLinks: Codable {
  let instagramUsername: String?
  let portfolioUrl: String?
  let twitterUsername: String?
}

struct Badge: Codable {
  let title: String
  let primary: Bool
  let slug: String
  let link: String
}
