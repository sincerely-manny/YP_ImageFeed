import UIKit

final class GradientView: UIView {
  override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }

  func setupGradient(colors: [UIColor], locations: [NSNumber]) {
    guard let gradientLayer = self.layer as? CAGradientLayer else { return }
    gradientLayer.colors = colors.map { $0.cgColor }
    gradientLayer.locations = locations
  }
}
