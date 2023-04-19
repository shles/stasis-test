//
//  AppDelegate.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/18/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow()
        window.rootViewController = UINavigationController(
            rootViewController:  CryptoViewController()
        )
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}

