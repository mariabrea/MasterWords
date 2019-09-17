//
//  AppDelegate.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift

let defaults = UserDefaults()

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
        
        //MARK: Migration block
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    print("lower squema version")
                    migration.enumerateObjects(ofType: User.className()) { (_, newUser) in
                        newUser?["avatar"] = "happyAvatar"
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        
        
        
        //if UserDefaults audio doesn't exist (first launch) set it to true
        if !defaults.exists(key: .audio) {
            defaults.set(true, forKey: .audio)
        }
        
        //increase 'timesAppLaunched'
        defaults.set(defaults.integer(forKey: .timesAppLaunched)+1, forKey: .timesAppLaunched)
        
        //set color of status bar
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(named: "colorBarBackground")
        //set the text of status bar light
        
        //copy bundled realm file if it doesn't exist already

        let initialURL = Bundle.main.url(forResource: "defaultCompactedMasterWords_v1.0", withExtension: "realm")

        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!

        print(FileManager.default)
        
        do {
            try _ = defaultURL.checkResourceIsReachable()
            print("The realm file already exists")
        } catch {
            print("The realm file does not exist")
            do {
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

