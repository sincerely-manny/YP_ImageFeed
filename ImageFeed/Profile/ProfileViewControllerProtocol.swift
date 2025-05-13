import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
  var presenter: ProfilePresenterProtocol? { get set }
  func updateAvatar(with url: URL?)
  func updateProfileDetails(name: String, loginName: String, bio: String?)
}
