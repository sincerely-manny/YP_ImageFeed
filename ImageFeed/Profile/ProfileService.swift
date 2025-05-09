import Foundation

final class ProfileService {
  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    assert(Thread.isMainThread)
    guard let request = getURLRequest() else { return }
    URLSession.shared.dataTask(with: request) { data, response, error in
      print("Response: \(String(describing: response))")
      print("Data: \(String(describing: data))")
      DispatchQueue.main.async {
        if let error = error {
          print("Error fetching profile: \(error)")
          completion(.failure(error))
        } else if let data = data {
          do {
            let text = String(data: data, encoding: .utf8)
            print("Data: \(String(describing: text))")
            let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
            let profile = Profile(
              username: profileResult.username,
              name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
              loginName: "@\(profileResult.username)",
              bio: profileResult.bio
            )
            completion(.success(profile))
          } catch {
            print("Error decoding profile response: \(error)")
            completion(.failure(error))
          }
        }
      }
    }.resume()
  }

  private func getURLRequest() -> URLRequest? {
    guard let baseUrl = Constants.apiBaseURL else { return nil }
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.path = "/me"
    guard let url = urlComponents?.url else { return nil }
    var request = URLRequest(url: url)
    request.setValue(
      "Bearer \(OAuth2Service.shared.accessToken ?? "")", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
    return request
  }
}

struct Profile {
  let username: String
  let name: String
  let loginName: String
  let bio: String?
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
  let downloads: Int
  let uploadsRemaining: Int
  let instagramUsername: String?
  let email: String?
  let links: ProfileLinks

  enum CodingKeys: String, CodingKey {
    case id
    case updatedAt = "updated_at"
    case username
    case firstName = "first_name"
    case lastName = "last_name"
    case twitterUsername = "twitter_username"
    case portfolioUrl = "portfolio_url"
    case bio, location
    case totalLikes = "total_likes"
    case totalPhotos = "total_photos"
    case totalCollections = "total_collections"
    case downloads
    case uploadsRemaining = "uploads_remaining"
    case instagramUsername = "instagram_username"
    case email, links
  }
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
