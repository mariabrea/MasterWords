//
//  TabBarViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/19/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 10)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 10)!], for: .selected)

    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let navigationController1 =  self.viewControllers![0] as? UINavigationController
        navigationController1!.popToRootViewController(animated: false)
        
        let navigationController2 =  self.viewControllers![1] as? UINavigationController
        navigationController2!.popToRootViewController(animated: false)
    }
    
}
