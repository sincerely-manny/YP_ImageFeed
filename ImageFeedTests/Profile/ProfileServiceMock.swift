import UIKit

@testable import ImageFeed

final class ProfileServiceMock: ProfileServiceProtocol {
  static let shared = ProfileServiceMock()
  var profile: Profile?
  let didChangeProfileImageNotification = Notification.Name(
    rawValue: "ProfileImageProviderDidChange")

  init() {
    self.profile = Profile(
      username: "test_username",
      name: "Test User",
      loginName: "@test_username",
      bio: "Test bio",
      avatar: URL(string: "https://example.com/avatar.jpg")
    )
  }

  func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
    if let profile = self.profile {
      completion(.success(profile))
    }
  }

  func fetchProfileAndTransition(to controllerIdentifier: String, completion: ((Error?) -> Void)?) {
    fetchProfile { _ in
      completion?(nil)
    }
  }
}
