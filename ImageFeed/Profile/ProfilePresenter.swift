import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.profileService = profileService
    }
    
    func viewDidLoad() {
        setupObserver()
        updateProfileDetails()
        updateAvatar()
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileService.profile?.avatar else {
            view?.updateAvatar(with: nil)
            return
        }
        view?.updateAvatar(with: profileImageURL)
    }
    
    func logoutButtonPressed() {
        OAuth2Service.shared.logout()
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: profileService.didChangeProfileImageNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio
        )
    }
}