//
//  TabBarViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 3.10.23.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarIconDesign()
        self.delegate = self
        configureTabBarControllers()
    }
    
    func configureTabBarControllers(){
        let cameraView = CameraViewController()
        let profile = ProfileViewController()
        let userReportedLocations = UserReportedLocationsViewController()
        
        let cameraBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName:"camera"), selectedImage:UIImage(systemName: "camera.fill"))
        cameraView.tabBarItem = cameraBarItem
        
        let profileBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName:"person.crop.circle"), selectedImage:UIImage(systemName: "person.crop.circle.fill"))
        profile.tabBarItem = profileBarItem
        
        let userLocationsBarItem = UITabBarItem(title: "All Reports", image: UIImage(systemName:"map"), selectedImage: UIImage(systemName: "map.fill"))
        userReportedLocations.tabBarItem = userLocationsBarItem
        
        let cameraNavC = NavigationController(rootViewController: cameraView)
        let profileNavC = NavigationController(rootViewController: profile)
        let userLocationsNavC = NavigationController(rootViewController: userReportedLocations)
        
        cameraNavC.setupNavigationController()
        profileNavC.setupNavigationController()
        userLocationsNavC.setupNavigationController()
        
        self.viewControllers = [cameraNavC, profileNavC,userLocationsNavC]
    }
    
    func tabBarIconDesign(){
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.defaultWhiteColor
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().tintColor = UIColor.tabBarNavBarColor
            UITabBar.appearance().unselectedItemTintColor = UIColor.tabBarNavBarColor
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
}
