import UIKit
@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false
    var setProgressValueCalled = false
    var setProgressHiddenCalled = false
    var lastRequest: URLRequest?
    var lastProgressValue: Float?
    var lastProgressHiddenValue: Bool?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        lastRequest = request
    }
    
    func setProgressValue(_ newValue: Float) {
        setProgressValueCalled = true
        lastProgressValue = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalled = true
        lastProgressHiddenValue = isHidden
    }
}
