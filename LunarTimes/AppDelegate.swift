//
//  AppDelegate.swift
//  LunarTimes
//
//  Created by Chase on 6/9/16.
//  Copyright © 2016 LetsHangLLC. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //UINavigationBar.appearance().barTintColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        
        FirebaseApp.configure()
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8223005482588566~5783734330")
        
        return true
    }
}

