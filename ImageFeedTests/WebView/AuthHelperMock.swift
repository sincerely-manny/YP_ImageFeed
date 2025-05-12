import Foundation
@testable import ImageFeed

final class AuthHelperMock: AuthHelperProtocol {
    var authRequestStub: URLRequest?
    var codeStub: String?
    
    func authRequest() -> URLRequest? {
        return authRequestStub
    }
    
    func code(from url: URL) -> String? {
        return codeStub
    }
}