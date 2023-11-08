//
//  NavigationController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 5.10.23.
//
//
import UIKit

class NavigationController: UINavigationController{
    func setupNavigationController(){
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.white
        
        UINavigationBar.appearance().tintColor = UIColor(named: "background")
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        
        let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBar.backgroundColor = UIColor(named: "primary")
        view.addSubview(statusBar)
        }
}
