//
//  AppDelegate.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 3.10.23.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn
import FBSDKCoreKit
import FacebookCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        return true
    }
    
    // for google signin
       func application(_ app: UIApplication,
         open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
       ) -> Bool {
         var handled: Bool

         handled = GIDSignIn.sharedInstance.handle(url)
         if handled {
           return true
         }
//
           ApplicationDelegate.shared.application(
                      app,
                      open: url,
                      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
                  )

         // If not handled by this app, return false.
         return false
       }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

