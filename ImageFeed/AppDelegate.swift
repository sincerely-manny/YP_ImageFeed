//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Кирилл Серебрянный on 09.03.2025.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Override point for customization after application launch.
    true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfiguration = UISceneConfiguration(
      name: "Main",
      sessionRole: connectingSceneSession.role
    )
    sceneConfiguration.delegateClass = SceneDelegate.self
    return sceneConfiguration
  }

}
