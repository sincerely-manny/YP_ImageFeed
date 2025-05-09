import Foundation

final class ProfileService {
  static let shared = ProfileService()
  var profile: Profile?
  let didChangeProfileImageNotification = Notification.Name(
    rawValue: "ProfileImageProviderDidChange")

  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  private init() {}

  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    assert(Thread.isMainThread)
    guard let request = APIURLRequest.getURLRequest(for: "/me") else { return }
    URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async { [weak self] in
        if let error = error {
          print("❌ Error fetching profile: \(error)")
          completion(.failure(error))
        } else if let data = data {
          do {
            guard let self = self else { return }
            let profileResult = try self.decoder.decode(ProfileResult.self, from: data)
            self.fecthProfileImageURL(username: profileResult.username)
            let profile = Profile(
              username: profileResult.username,
              name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
              loginName: "@\(profileResult.username)",
              bio: profileResult.bio,
              avatar: nil
            )
            self.profile = profile
            completion(.success(profile))
          } catch {
            print("❌ Error decoding profile response: \(error)")
            completion(.failure(error))
          }
        }
      }
    }.resume()
  }

  private func fecthProfileImageURL(username: String) {
    let service = ProfileImageService()
    var profileImageURL: URL?
    service.fetchProfileImageURL(username: username) { result in
      switch result {
      case .success(let url):
        profileImageURL = URL(string: url)
        self.profile?.avatar = profileImageURL
        NotificationCenter.default.post(name: self.didChangeProfileImageNotification, object: nil)
      case .failure(let error):
        print("❌ Error fetching profile image URL: \(error)")
      }
    }
  }

}
