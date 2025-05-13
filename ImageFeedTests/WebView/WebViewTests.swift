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

  func testProgressVisibleWhenLessThenOne() {
    //given
    let authHelper = AuthHelper()
    let presenter = WebViewPresenter(authHelper: authHelper)
    let progress: Float = 0.6

    //when
    let shouldHideProgress = presenter.shouldHideProgress(for: progress)

    //then
    XCTAssertFalse(shouldHideProgress)
  }

  func testProgressHiddenWhenOne() {
    //given
    let authHelper = AuthHelper()
    let presenter = WebViewPresenter(authHelper: authHelper)
    let progress: Float = 1.0

    //when
    let shouldHideProgress = presenter.shouldHideProgress(for: progress)

    //then
    XCTAssertTrue(shouldHideProgress)
  }

  func testAuthHelperAuthURL() {
    //given
    let configuration = AuthConfiguration.standard
    let authHelper = AuthHelper(configuration: configuration)

    //when
    let url = authHelper.authURL()

    guard let urlString = url?.absoluteString else {
      XCTFail("Auth URL is nil")
      return
    }

    //then
    XCTAssertTrue(urlString.contains(configuration.defaultBaseURL.absoluteString))
    XCTAssertTrue(urlString.contains(configuration.accessKey))
    XCTAssertTrue(urlString.contains(configuration.redirectURI))
    XCTAssertTrue(urlString.contains("code"))
    XCTAssertTrue(urlString.contains(configuration.accessScope))
  }

  func testCodeFromURL() {
    //given
    var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
    urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
    let url = urlComponents.url!
    let authHelper = AuthHelper()

    //when
    let code = authHelper.code(from: url)

    //then
    XCTAssertEqual(code, "test code")
  }
}
