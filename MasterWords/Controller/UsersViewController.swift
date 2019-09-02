//
//  UsersViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class UsersViewController: UIViewController {

    @IBOutlet weak var user1Button: UIButton!
    @IBOutlet weak var user2Button: UIButton!
    @IBOutlet weak var user1Label: UILabel!
    @IBOutlet weak var user2Label: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    //CODE FOR DATABASE MIGRATION
    let config = Realm.Configuration(
        schemaVersion: 1,
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: User.className()) { (_, newUser) in
                    newUser?["avatar"] = "happyAvatar"
                }
            }
    })

    lazy var realm = try! Realm(configuration: config)
    
//    let realm = try! Realm()
    
    var user : String = ""
    
    var users : Results<User>?
    var selectedUser = User()
    
    override func viewDidLoad() {
        print("in pre viewDidLoad")

        super.viewDidLoad()
        
        print("in viewDidLoad")

//      used to load some default users
//        writeUsers()
        
        loadUsers()
        
//        deleteUsers()
        
//        writeUsers()
        
//        loadUsers()
        
        updateUI()
        
    }

    //MARK: - Database Methods
    func loadUsers(){
        
        users = realm.objects(User.self).sorted(byKeyPath: "name", ascending: true)
        
        print(users?.count as Any)
        print(users as Any)

    }
    
    func deleteUsers() {
        
        do{
            try self.realm.write {
                self.realm.delete(users!)
            }
        } catch {
            print("Error deleting users \(error)")
        }
        
    }
    
    func writeUsers() {
        
        let user1 = User()
        user1.name = "User 1"
        user1.avatar = "coolAvatar"
        
        let user2 = User()
        user2.name = "User 2"
        user2.avatar = "happyAvatar"
        
        do {
            try realm.write {
                realm.add(user1)
                realm.add(user2)
            }
        } catch {
            print("Error saving users \(error)")
        }
    }
    
    func updateUI() {
        
        titleLabel.textColor = FlatPlum()
        user1Label.text = users![0].name
        user1Label.textColor = FlatPlum()
        user2Label.text = users![1].name
        user2Label.textColor = FlatPlum()
        user1Button.setImage(UIImage(named: users![0].avatar), for: .normal)
        user2Button.setImage(UIImage(named: users![1].avatar), for: .normal)
        
    }
    // MARK: - Navigation Methods
    @IBAction func unwindToUsersMenu(segue: UIStoryboardSegue) {
        
        print("Segue unwindToUsersMenu performed")
        
    }

    
    
    @IBAction func user1Tapped(_ sender: UIButton) {
        selectedUser = users![0]
        performSegue(withIdentifier: "goToTabBarVC", sender: self)
    }
    
    @IBAction func user2Tapped(_ sender: UIButton) {
        selectedUser = users![1]
        performSegue(withIdentifier: "goToTabBarVC", sender: self)
    }
    
    
    @IBAction func creditsButtonTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "segueToCreditsVC", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("Calling prepare for segue in UsersViewController:")
        print(segue.identifier)
        
        if segue.identifier == "goToTabBarVC" {
            let barViewControllers = segue.destination as! UITabBarController
            
            let destinationVC1 = barViewControllers.viewControllers![3] as! UserEditViewController
            destinationVC1.selectedUser = selectedUser
            
            let nav1 = barViewControllers.viewControllers![0] as! UINavigationController
            let destinationVC2 = nav1.topViewController as! ListsEditViewController
            destinationVC2.selectedUser = selectedUser
            
            let nav2 = barViewControllers.viewControllers![1] as! UINavigationController
            let destinationVC3 = nav2.topViewController as! ListsTableViewController
            destinationVC3.selectedUser = selectedUser
            
            let destinationVC4 = barViewControllers.viewControllers![2] as! GraphTableViewController
            destinationVC4.selectedUser = selectedUser
            
            let destinationVC5 = barViewControllers.viewControllers![4] as! SwitchUserViewController
            destinationVC5.selectedUser = selectedUser
            
        }
        
    }
}
