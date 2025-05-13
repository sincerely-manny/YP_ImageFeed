import UIKit

@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
  var presenter: ProfilePresenterProtocol?
  var updateAvatarCalled = false
  var lastAvatarURL: URL?
  var updateProfileDetailsCalled = false
  var lastProfileName: String?
  var lastLoginName: String?
  var lastBio: String?

  func updateAvatar(with url: URL?) {
    updateAvatarCalled = true
    lastAvatarURL = url
  }

  func updateProfileDetails(name: String, loginName: String, bio: String?) {
    updateProfileDetailsCalled = true
    lastProfileName = name
    lastLoginName = loginName
    lastBio = bio
  }
}
