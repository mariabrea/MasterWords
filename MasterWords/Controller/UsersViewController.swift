//
//  UsersViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
//import ChameleonFramework

class UsersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usersPickerView: UIPickerView!
    @IBOutlet weak var startButton: RoundButton!
    
    
    // MARK: - DB Migration
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
//    lazy var realm = try! Realm()
    
    var user : String = ""
    
    var users : Results<User>?
    var selectedUser = User()
    
    var rotationAnglePositive: CGFloat!
    var rotationAngleNegative: CGFloat!
    
    override func viewDidLoad() {
        print("in pre viewDidLoad")

        super.viewDidLoad()

//        UIApplication.shared.statusBarView?.backgroundColor = UIColor(named: "colorButtonBackground")
        

//        createDefaultDB()
        
        loadUsers()

        updateUI()
        
    }

    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: File DB Methods
    
    func createDefaultDB() {
        
//        deleteAllDB()
//        writeUsers()
        makeCompactedCopyDBFile()
        
    }
    
    func makeCompactedCopyDBFile() {
    
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL
        let defaultParentURL = defaultURL?.deletingLastPathComponent()
        let compactedURL = defaultParentURL?.appendingPathComponent("defaultCompactedMasterWords.realm")
        
        try! realm.writeCopy(toFile: compactedURL!)

    }
    
    //MARK: PickerView Methods
    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return users?.count ?? 1
//        return 4
    }
    
    // When user selects an option, this function will set the text of the text field to1 reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedUser = users![row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 180
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let userView = UIView(frame: CGRect(x: 0, y: 20, width: 150, height: 160))
        
        //        userView.backgroundColor = UIColor.blue
        
        let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 130))
        //        userImageView.backgroundColor = UIColor.red
        userImageView.contentMode = .scaleAspectFit
        userView.addSubview(userImageView)
        
//        userImageView.image = UIImage(named: "coolAvatar")
        userImageView.image = UIImage(named: users?[row].avatar ?? "happyAvatar")
        
        let userLabel = UILabel(frame: CGRect(x: 0, y: 130, width: 150, height: 30))
//        userLabel.text = "Name"
        userLabel.text = users?[row].name
        userLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        userLabel.textColor = UIColor(named: "colorBarBackground")
        userLabel.textAlignment = .center
        //        userLabel.backgroundColor = UIColor.yellow
        
        userView.addSubview(userLabel)
        
        userView.transform = CGAffineTransform(rotationAngle: rotationAnglePositive)
        
        //in case the pickerView is not used (with the first users) the function didSelectRow won't be called, then we assign the first user by default value
        
        selectedUser = users![0]
        
        return userView
        
    }
    
    //eliminate lines of pickerView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for i in [1,2] {
            usersPickerView.subviews[i].isHidden = true
        }
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
    
    func deleteAllDB() {
        
        do {
            try self.realm.write {
                self.realm.deleteAll()
            }
        } catch {
            print("Error deleting DB \(error)")
        }

    }
    
    func writeUsers() {
        
        let user1 = User()
        user1.name = "User 1"
        user1.avatar = "happyAvatar"
        
        let user2 = User()
        user2.name = "User 2"
        user2.avatar = "happyAvatar"
        
        let user3 = User()
        user3.name = "User 3"
        user3.avatar = "happyAvatar"
        
        let user4 = User()
        user4.name = "User 4"
        user4.avatar = "happyAvatar"
        
        do {
            try realm.write {
                realm.add(user1)
                realm.add(user2)
                realm.add(user3)
                realm.add(user4)
            }
        } catch {
            print("Error saving users \(error)")
        }
    }
    
    // MARK: - Navigation Methods
    
    func updateUI() {
        
        usersPickerView.delegate = self
        usersPickerView.dataSource = self
        
        titleLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.1411764706, blue: 0.3058823529, alpha: 1)
        
        rotationAngleNegative = -90 * (.pi/180)
        rotationAnglePositive = 90 * (.pi/180)
        
        usersPickerView.transform = CGAffineTransform(rotationAngle: rotationAngleNegative)
        
    }
    // MARK: - IBAction Methods
    
    @IBAction func unwindToUsersMenu(segue: UIStoryboardSegue) {
        
        print("Segue unwindToUsersMenu performed")
        
    }
    
    
    @IBAction func startButtonTapped(_ sender: RoundButton) {
//        selectedUser = users![0]
        performSegue(withIdentifier: "goToTabBarVC", sender: self)
    }
    
//    @IBAction func user1Tapped(_ sender: UIButton) {
//        selectedUser = users![0]
//        performSegue(withIdentifier: "goToTabBarVC", sender: self)
//    }
    
    @IBAction func creditsButtonTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "segueToCreditsVC", sender: self)
        
    }
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
