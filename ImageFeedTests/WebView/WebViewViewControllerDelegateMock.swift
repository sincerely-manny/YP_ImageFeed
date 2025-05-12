import Foundation
@testable import ImageFeed

final class WebViewViewControllerDelegateMock: WebViewViewControllerDelegate {
    var didAuthenticateWithCodeCalled = false
    var didCancelCalled = false
    var lastCode: String?
    var lastViewController: WebViewViewController?
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        didAuthenticateWithCodeCalled = true
        lastViewController = vc
        lastCode = code
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        didCancelCalled = true
        lastViewController = vc
    }
}