//
//  AppDelegate.swift
//  LunarTimes
//
//  Created by Chase on 6/9/16.
//  Copyright © 2016 LetsHangLLC. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = ColorsConfig.primary
        navBarAppearance.titleTextAttributes = [.foregroundColor: ColorsConfig.accent]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: ColorsConfig.accent]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = ColorsConfig.accent

        let locationStore = LocationStore()
        let tabBar = TabBarViewController(locationStore: locationStore)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
        return true
    }
}

