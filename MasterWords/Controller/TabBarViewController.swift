//
//  TabBarViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/19/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    let defaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//      //center images of tabbar if we dont use titles
//        if let items = tabBarController?.tabBar.items {
//            for item in items {
//                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //select tab of SwitchUser when logOut notofocation posted
        NotificationCenter.default.addObserver(self, selector: #selector(logOut), name: NSNotification.Name(rawValue: "logOut"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        print("removing observer in tabbarController")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func logOut() {
//        print("setting default automaticlogout to true")
        defaults.set(true, forKey: .automaticLogOut)
        self.selectedIndex = 4
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let navigationController1 =  self.viewControllers![0] as? UINavigationController
        navigationController1!.popToRootViewController(animated: false)
        
        let navigationController2 =  self.viewControllers![1] as? UINavigationController
        navigationController2!.popToRootViewController(animated: false)
    }
    
    
    
}
