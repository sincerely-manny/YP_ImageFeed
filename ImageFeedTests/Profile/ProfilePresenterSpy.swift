import UIKit
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var updateAvatarCalled = false
    var logoutButtonPressedCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func logoutButtonPressed() {
        logoutButtonPressedCalled = true
    }
}