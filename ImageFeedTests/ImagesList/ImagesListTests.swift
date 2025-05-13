import XCTest

@testable import ImageFeed

final class ImagesListTests: XCTestCase {
  // Test that the view controller calls the presenter's viewDidLoad method
  func testViewControllerCallsViewDidLoad() {
    // Given
    let viewController = ImagesListViewController()
    let presenter = ImagesListPresenterSpy()
    viewController.presenter = presenter
    presenter.view = viewController

    // When
    _ = viewController.view

    // Then
    XCTAssertTrue(presenter.viewDidLoadCalled)
  }

  // Test that the presenter properly handles the setting of likes
  func testPresenterToggleLike() {
    // Given
    let viewController = ImagesListViewControllerSpy()
    let imagesService = ImagesListServiceMock()
    let presenter = ImagesListPresenter(imagesListService: imagesService)
    viewController.presenter = presenter
    presenter.view = viewController

    let photo = imagesService.photos[0]  // First test photo (not liked)

    // When
    presenter.toggleLike(for: photo)

    // Then
    XCTAssertTrue(imagesService.setLikeCalled)
    XCTAssertEqual(imagesService.lastPhotoLiked?.id, photo.id)
    XCTAssertEqual(imagesService.lastLikeState, true)  // Should toggle to true since original is false
  }

  // Test that notifications correctly update the view
  func testPresenterNotifiesViewOnPhotoListChange() {
    // Given
    let viewController = ImagesListViewControllerSpy()
    let imagesService = ImagesListServiceMock()
    let presenter = ImagesListPresenter(imagesListService: imagesService)
    viewController.presenter = presenter
    presenter.view = viewController

    // Initialize the presenter to set up observers
    presenter.viewDidLoad()

    // When - simulate a list change notification
    NotificationCenter.default.post(
      name: ImagesListServiceMock.didChangeListNotification,
      object: nil
    )

    // Then
    XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
  }

  // Test that presenter correctly responds to item changes
  func testPresenterNotifiesViewOnPhotoItemChange() {
    // Given
    let viewController = ImagesListViewControllerSpy()
    let imagesService = ImagesListServiceMock()
    let presenter = ImagesListPresenter(imagesListService: imagesService)
    viewController.presenter = presenter
    presenter.view = viewController

    // Initialize the presenter to set up observers
    presenter.viewDidLoad()

    let photo = imagesService.photos[0]
    let index = 0

    // When - simulate an item change notification
    NotificationCenter.default.post(
      name: ImagesListServiceMock.didChangeItemNotification,
      object: nil,
      userInfo: [
        "photo": photo,
        "index": index,
      ]
    )

    // Then
    XCTAssertTrue(viewController.updateCellCalled)
    XCTAssertEqual(viewController.lastIndexForUpdateCell, index)
    XCTAssertEqual(viewController.lastPhotoForUpdateCell?.id, photo.id)

    XCTAssertTrue(viewController.configureFullscreenVCCalled)
    XCTAssertEqual(viewController.lastPhotoForFullscreenVC?.id, photo.id)
    XCTAssertEqual(viewController.lastIsLikedForFullscreenVC, photo.isLiked)
  }

  // Test that fetching next page is called properly
  func testPresenterFetchesNextPageAtMiddleOfLastPage() {
    // Given
    let viewController = ImagesListViewControllerSpy()
    let imagesService = ImagesListServiceMock()
    let presenter = ImagesListPresenter(imagesListService: imagesService)
    viewController.presenter = presenter
    presenter.view = viewController

    // Add more photos to reach a page size
    for i in 0..<(ImagesListServiceConstants.pageSize - 2) {
      let photo = Photo(
        id: "test_id_\(i+3)",
        size: CGSize(width: 100, height: 100),
        createdAt: Date(),
        welcomeDescription: "Test photo \(i+3)",
        thumbImageURL: "https://example.com/thumb\(i+3).jpg",
        largeImageURL: "https://example.com/large\(i+3).jpg",
        isLiked: false
      )
      imagesService.photos.append(photo)
    }

    // When - simulate scrolling to the middle of the last page
    let middleIndex = imagesService.photos.count - (ImagesListServiceConstants.pageSize / 2)
    presenter.fetchPhotosNextPage(at: IndexPath(row: middleIndex, section: 0))

    // Then
    XCTAssertTrue(imagesService.fetchPhotosNextPageCalled)
  }
}
