import UIKit

final class TabBarController: UITabBarController {
  override func awakeFromNib() {
    super.awakeFromNib()
    let imagesListViewController = ImagesListViewController()
    let profileViewController = ProfileViewController()
    profileViewController.tabBarItem = UITabBarItem(
      title: "",
      image: UIImage(named: "tab_profile_active"),
      selectedImage: nil
    )
    imagesListViewController.tabBarItem = UITabBarItem(
      title: "",
      image: UIImage(named: "tab_editorial_active"),
      selectedImage: nil
    )
    self.viewControllers = [imagesListViewController, profileViewController]
  }
}
