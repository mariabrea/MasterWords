//
//  UsersViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import MaterialShowcase
import SCLAlertView

class UsersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MaterialShowcaseDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usersPickerView: UIPickerView!
    @IBOutlet weak var startButton: RoundButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    

    lazy var realm = try! Realm()
    
    var user : String = ""
    
    var users : Results<User>?
    var selectedUser = User()
    var lists : Results<SightWordsList>?
    var wordsList : Results<SightWord>?
    
    var rotationAnglePositive: CGFloat!
    var rotationAngleNegative: CGFloat!
    
    let sequenceShowcases = MaterialShowcaseSequence()
    let showcaseStartButton = MaterialShowcase()
    let showcaseCreateButton = MaterialShowcase()
    let showcaseDeleteButton = MaterialShowcase()
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        
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

        let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 130))

        userImageView.contentMode = .scaleAspectFit
        userView.addSubview(userImageView)
        
        userImageView.image = UIImage(named: users?[row].avatar ?? "happyAvatar")
        
        let userLabel = UILabel(frame: CGRect(x: 0, y: 130, width: 150, height: 30))

        userLabel.text = users?[row].name
        userLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        userLabel.textColor = UIColor(named: "colorBarBackground")
        userLabel.textAlignment = .center

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

    }
    
    func loadLists() {
        
        lists = selectedUser.userLists.sorted(byKeyPath: "name", ascending: true)
        
    }
    
    func loadSightWords() {
        
        wordsList = realm.objects(SightWord.self).filter("userName = %@", selectedUser.name as Any)
        
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
    
    func deleteUser() {
        
        //we delete all the sight words of the user
        loadSightWords()
        wordsList?.forEach { wordToDelete in
            do {
                try realm.write {
                    realm.delete(wordToDelete)
                }
            } catch {
                print("Error deleting sight word \(error)")
            }
        }
        //we delete all the lists of the user
        loadLists()
        lists?.forEach { listToDelete in
            do {
                try realm.write {
                    realm.delete(listToDelete)
                }
            } catch {
                print("Error deleting list \(error)")
            }
        }
        //we delete the user
        do {
            try realm.write {
                realm.delete(selectedUser)
            }
        } catch {
            print("Error deleting user \(error)")
        }
        
    }
    
    func writeUsers() {
        
        let user1 = User()
        user1.name = "User"
        user1.avatar = "happyAvatar"
        
        do {
            try realm.write {
                realm.add(user1)
            }
        } catch {
            print("Error saving users \(error)")
        }
    }
    
    // MARK: - Navigation Methods
    
    func updateUI() {
        
        let helpImage = UIImage(named: "iconHelp")
        let helpImageTinted = helpImage?.withRenderingMode(.alwaysTemplate)
        helpButton.setImage(helpImageTinted, for: .normal)
        helpButton.tintColor = UIColor.white
        
        let createImage = UIImage(named: "iconPlus")
        let createImageTinted = createImage?.withRenderingMode(.alwaysTemplate)
        createButton.setImage(createImageTinted, for: .normal)
        createButton.tintColor = UIColor.white
        
        let deleteImage = UIImage(named: "iconErase")
        let deleteImageTinted = deleteImage?.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(deleteImageTinted, for: .normal)
        deleteButton.tintColor = UIColor.white
        
        let settingsImage = UIImage(named: "iconSettings")
        let settingsImageTinted = settingsImage?.withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(settingsImageTinted, for: .normal)
        settingsButton.tintColor = UIColor.white
        
        usersPickerView.delegate = self
        usersPickerView.dataSource = self
        
        titleLabel.textColor = #colorLiteral(red: 0.2862745098, green: 0.1411764706, blue: 0.3058823529, alpha: 1)
        
        rotationAngleNegative = -90 * (.pi/180)
        rotationAnglePositive = 90 * (.pi/180)
        
        usersPickerView.transform = CGAffineTransform(rotationAngle: rotationAngleNegative)
        
    }
    
    func startShowcase() {

        showcaseStartButton.setTargetView(view: startButton)
        showcaseStartButton.primaryText = "Start Button"
        showcaseStartButton.secondaryText = "Click here to start practicing."

        designShowcase(showcase: showcaseStartButton, sizeHolder: "big")
        

        showcaseCreateButton.setTargetView(view: createButton)
        showcaseCreateButton.primaryText = "Create Button"
        showcaseCreateButton.secondaryText = "Click here to create a new user. A maximun of 4 users are allowed."

        designShowcase(showcase: showcaseCreateButton)
        

        showcaseDeleteButton.setTargetView(view: deleteButton)
        showcaseDeleteButton.primaryText = "Delete Button"
        showcaseDeleteButton.secondaryText = "Click here to delete the user."

        designShowcase(showcase: showcaseDeleteButton)
        
        showcaseStartButton.delegate = self
        showcaseCreateButton.delegate = self
        showcaseDeleteButton.delegate = self
         sequenceShowcases.temp(showcaseCreateButton).temp(showcaseDeleteButton).temp(showcaseStartButton).start()

    }
    
    //MARK: Material Showcase Delegate Methods
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func unwindToUsersMenu(segue: UIStoryboardSegue) {
        
        print("Segue unwindToUsersMenu performed")
        
    }
    
    
    @IBAction func startButtonTapped(_ sender: RoundButton) {

        performSegue(withIdentifier: "goToTabBarVC", sender: self)
    }
   
    @IBAction func createButtonTapped(_ sender: UIButton) {
        
        //check that there are less than 4 users
        if users?.count == 4 {
            //create alert: no more than 4 users allowed
            let appearance = SCLAlertView.SCLAppearance(
                kButtonHeight: 50,
                kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
                kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
                kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
                
            )
            let alert = SCLAlertView(appearance: appearance)
            let colorAlert = UIColor(named: "colorAlertEdit")
            let iconAlert = UIImage(named: "icon-warning")
            
            alert.showCustom("Limit reached", subTitle: "Only 4 users allowed", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
            
        } else {

            performSegue(withIdentifier: "segueToUsersEditVC", sender: self)
            
        }
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        
        //check that there are at least 2 users
        if users?.count == 1 {
            //create alert: at least 1 user must exist
            let appearance = SCLAlertView.SCLAppearance(
                kButtonHeight: 50,
                kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
                kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
                kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
                
            )
            let alert = SCLAlertView(appearance: appearance)
            let colorAlert = UIColor(named: "colorAlertEdit")
            let iconAlert = UIImage(named: "icon-warning")
            
            alert.showCustom("Last user", subTitle: "At least one user must exist", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
            
        } else {
            
            deleteUser()
            usersPickerView.reloadAllComponents()
            
        }
        
    }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        
        startShowcase()
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
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
        
        if segue.identifier == "segueToUsersEditVC" {
            
            let destinationVC = segue.destination as? UserEditViewController
            destinationVC?.action = "create"
            
        }
        
    }
}
