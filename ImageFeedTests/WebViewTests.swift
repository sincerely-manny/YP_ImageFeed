import XCTest

@testable import ImageFeed

final class WebViewTests: XCTestCase {
  func testViewControllerCallsViewDidLoad() {
    //given
    let delegate = WebViewViewControllerDelegateMock()
    let viewController = WebViewViewController(delegate: delegate)
    let presenter = WebViewPresenterSpy()
    viewController.presenter = presenter
    presenter.view = viewController

    //when
    _ = viewController.view

    //then
    XCTAssertTrue(presenter.viewDidLoadCalled)
  }

  func testPresenterCallsLoadRequest() {
    //given
    let viewController = WebViewViewControllerSpy()
    let authHelper = AuthHelperMock()
    let presenter = WebViewPresenter(authHelper: authHelper)
    viewController.presenter = presenter
    presenter.view = viewController

    let testRequest = URLRequest(url: URL(string: "https://unsplash.com")!)
    authHelper.authRequestStub = testRequest

    //when
    presenter.viewDidLoad()

    //then
    XCTAssertTrue(viewController.loadRequestCalled)
    XCTAssertEqual(viewController.lastRequest, testRequest)
  }
}
