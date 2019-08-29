//
//  AppDelegate.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        //
        
        print("in appDelegate")
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        do {
            let _ =  try Realm()
        } catch {
            print("Error initialising realm \(error)")
        }
        
        return true
    }
    
}

