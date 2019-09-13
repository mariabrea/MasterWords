//
//  AppDelegate.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: - Copy default Realm Database

func bundleURL(_ name: String) -> URL? {
    return Bundle.main.url(forResource: name, withExtension: "realm")
}

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
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(named: "colorBarBackground")
        //set the text of status bar light
        
        //copy bundled realm file if it doesn't exist already
        print("1")
        let initialURL = Bundle.main.url(forResource: "defaultCompactedMasterWords_v1.0", withExtension: "realm")
        print("2")
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
        print("3")
        print(FileManager.default)
        
        do {
            try defaultURL.checkResourceIsReachable()
            print("The realm file already exists")
        } catch {
            print("The file does not exist")
            print("4")
            do {
                print("5")
                try FileManager.default.copyItem(at: initialURL!, to: defaultURL)
            } catch {
                print("Error copying bundled realm file")
            }
        }
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        do {
            let _ =  try Realm()
            print("Realm initialized")
        } catch {
            print("Error initialising realm \(error)")
        }
        
        return true
    }

    
}

