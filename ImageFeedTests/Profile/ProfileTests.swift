import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceMock.shared
        let presenter = ProfilePresenter(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.lastProfileName, "Test User")
        XCTAssertEqual(viewController.lastLoginName, "@test_username")
        XCTAssertEqual(viewController.lastBio, "Test bio")
    }
    
    func testPresenterCallsUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceMock.shared
        let presenter = ProfilePresenter(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.lastAvatarURL, URL(string: "https://example.com/avatar.jpg"))
    }
    
    func testLogoutButtonPressed() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        
        //when
        presenter.logoutButtonPressed()
        
        //then
        XCTAssertTrue(presenter.logoutButtonPressedCalled)
    }
}