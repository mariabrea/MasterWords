//
//  AppDelegate.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift



//extension to chamge background color of status bar
extension UIApplication {

    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        //
        
        //set color of status bar
        UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.1411764706, blue: 0.3058823529, alpha: 1)
        //set the text of status bar light
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        do {
            let _ =  try Realm()
        } catch {
            print("Error initialising realm \(error)")
        }
        
        return true
    }

    
}

