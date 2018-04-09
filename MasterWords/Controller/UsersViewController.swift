//
//  UsersViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift

class UsersViewController: UIViewController {

    let realm = try! Realm()
    
    var user : String = ""
    
    var users : Results<User>?
    var selectedUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //writeUsers()
        
        loadUsers()
        
        // Do any additional setup after loading the view.
    }

    //MARK: - Database Methods
    func loadUsers(){
        
        users = realm.objects(User.self).sorted(byKeyPath: "name", ascending: true)
        print(users)
//        do {
//            try realm.write {
//                realm.delete(users![2])
////                realm.delete(users![3])
//            }
//        } catch {
//            print("Error saving users \(error)")
//        }
//        print(users)
    }
    
    func writeUsers() {
        
        let user1 = User()
        user1.name = "Maria"
        
        let user2 = User()
        user2.name = "Samuel"
        
        do {
            try realm.write {
                realm.add(user1)
                realm.add(user2)
            }
        } catch {
            print("Error saving users \(error)")
        }
    }
    
    // MARK: - Navigation Methods
    @IBAction func unwindToUsersMenu(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func user1Tapped(_ sender: UIButton) {
        selectedUser = users![0]
        performSegue(withIdentifier: "goToTabBarVC", sender: self)
    }
    
    @IBAction func user2Tapped(_ sender: UIButton) {
        selectedUser = users![1]
        performSegue(withIdentifier: "goToTabBarVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let barViewControllers = segue.destination as! UITabBarController
        let nav1 = barViewControllers.viewControllers![0] as! UINavigationController
        let destinationVC1 = nav1.topViewController as! ListsEditViewController
        destinationVC1.selectedUser = selectedUser
        
        let nav2 = barViewControllers.viewControllers![1] as! UINavigationController
        let destinationVC2 = nav2.topViewController as! ListsTableViewController
        destinationVC2.selectedUser = selectedUser
        
        let destinationVC3 = barViewControllers.viewControllers![2] as! GraphTableViewController
        destinationVC3.selectedUser = selectedUser
        
    }
}
