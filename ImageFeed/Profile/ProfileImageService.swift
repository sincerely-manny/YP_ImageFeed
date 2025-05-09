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

    URLSession.shared.objectTask(for: request) { (result: Result<PublicProfileResult, Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let profileResult):
          guard let profileImageURL = profileResult.profileImage?.large else {
            completion(.failure(ProfileImageError.invalidResponse))
            return
          }
          completion(.success(profileImageURL))
        case .failure(let error):
          print("Error fetching profile image URL: \(error)")
          completion(.failure(error))
        }
      }
    }.resume()
  }
}
