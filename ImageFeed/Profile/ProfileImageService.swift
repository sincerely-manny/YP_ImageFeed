import Foundation

enum ProfileImageError: Error {
  case invalidURL
  case invalidResponse
  case decodingError
}

final class ProfileImageService {
  private lazy var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func fetchProfileImageURL(
    username: String, _ completion: @escaping (Result<String, Error>) -> Void
  ) {
    guard let request = APIURLRequest.getURLRequest(for: "/users/\(username)") else {
      completion(.failure(ProfileImageError.invalidURL))
      return
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          print("Error fetching profile image URL: \(error)")
          completion(.failure(error))
        } else if let data = data {
          do {
            let profileResult = try self.decoder.decode(PublicProfileResult.self, from: data)
            guard let profileImageURL = profileResult.profileImage?.large else {
              completion(.failure(ProfileImageError.invalidResponse))
              return
            }
            completion(.success(profileImageURL))
          } catch {
            print("Error decoding profile image URL response: \(error)")
            completion(.failure(error))
          }
        }
      }
    }.resume()
  }
}
