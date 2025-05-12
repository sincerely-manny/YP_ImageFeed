import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get set }
    var didChangeProfileImageNotification: Notification.Name { get }
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    func fetchProfileAndTransition(to controllerIdentifier: String, completion: ((Error?) -> Void)?)
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    var profile: Profile?
    let didChangeProfileImageNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange")
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let request = APIURLRequest.getURLRequest(for: "/me") else { return }
        URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let profileResult):
                    self.fetchProfileImageURL(username: profileResult.username)
                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio,
                        avatar: nil
                    )
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("❌ [ProfileService] Error fetching profile: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchProfileAndTransition(
        to controllerIdentifier: String, completion: ((Error?) -> Void)? = nil
    ) {
        fetchProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    transitionToViewController(controllerIdentifier: controllerIdentifier)
                    completion?(nil)
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                    completion?(error)
                }
            }
        }
    }

    private func fetchProfileImageURL(username: String) {
        let service = ProfileImageService()
        var profileImageURL: URL?
        service.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                profileImageURL = URL(string: url)
                self.profile?.avatar = profileImageURL
                NotificationCenter.default.post(name: self.didChangeProfileImageNotification, object: nil)
            case .failure(let error):
                print("❌ Error fetching profile image URL: \(error)")
            }
        }
    }

}
