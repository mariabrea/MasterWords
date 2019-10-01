//
//  ListsEditViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import MaterialShowcase
import SCLAlertView

class ListsEditViewController: SwipeTableViewController, MaterialShowcaseDelegate, UITextFieldDelegate{

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var helpButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    var lists : List<SightWordsList>?
    var listsCheck : Results<SightWordsList>?
    var wordsList : Results<SightWord>?
    
//    var listPreK = SightWordsList()
//    var listKindergarten = SightWordsList()
//    var listFirstGrade = SightWordsList()
//    var listSecondGrade = SightWordsList()
//    var listThirdGrade = SightWordsList()
    
//    var sightWordsPreK = List<SightWord>()
//    var sightWord = SightWord()
//    var user = User()
    
    var selectedUser : User? {
        didSet{
            loadLists()
        }
    }
    
    var lastListColor =  String()
    
    let sequenceShowcases = MaterialShowcaseSequence()
    let showcaseAddButton = MaterialShowcase()
    let showcaseListRow = MaterialShowcase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set observer to detetct when Lists have been added through the Graph window
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLists), name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        
        self.navigationItem.title = "\(selectedUser!.name)'s Lists"
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let navBar = self.navigationController?.navigationBar {
            navBar.barStyle = UIBarStyle.black
        }
        
    }
    
    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if categories is nil return 1
        return lists?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let list = lists?[indexPath.row]{
            cell.textLabel?.text  = list.name
            guard let listColor = UIColor(hexString: list.color) else {fatalError()}
            cell.backgroundColor = listColor
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:listColor, isFlat:true)
            cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)
            
        }
        
        return cell
    }
    
    //MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSingleListEditVC", sender: self)
    }
    
    
    //MARK: Data Manipulation Methods
    
    //save the context in the database
    func save(list : SightWordsList) {
        
        do {
            try realm.write {
                realm.add(list)
            }
        } catch {
            print("Error saving list \(error)")
        }
        
    }
    
    func loadLists() {

        lists = selectedUser?.userLists
        if lists?.count ?? 0 > 0 {
            lastListColor = lists?.last?.color ?? "#FFFFFF"
        }

        tableView.reloadData()
        
    }
    
    //func to reload data when Lists have been added through the Graph window
    @objc func reloadLists(notification: NSNotification) {
//        print("ListsEditViewController reloading lists")
        self.tableView.reloadData()
        
    }
    
    func loadSightWords(selectedList: SightWordsList) {
        
        wordsList = selectedList.sightWords.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
        
    }
    
    //function to check is a List name already exists for the user
    func checkListExist(listName: String) -> Bool {
        print("checking list already exists")
        listsCheck = selectedUser?.userLists.filter("name = %@", listName)
        if listsCheck?.count ?? 0 >= 1 {
            print("list exists")
            return true
        } else {
            print("list does not exist")
            return false
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath, delete: Bool) {
        
        if delete {
            if let list = self.lists?[indexPath.row] {
                //first we delete all the sight words of the list
                loadSightWords(selectedList: list)
                wordsList?.forEach { wordToDelete in
                    do {
                        try self.realm.write {
                            self.realm.delete(wordToDelete)
                        }
                    } catch {
                        print("Error deleting sight word \(error)")
                    }
                }
                //second we delete the list
                do{
                    try self.realm.write {
                        self.realm.delete(list)
                    }
                } catch {
                    print("Error deleting list \(error)")
                }
            }
            //notify to NotificacionCenter when data has changed
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
            //we post in the notification Center 'loadGraph' so the graph is updated
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadGraph"), object: nil)
        } else {

            let appearance = SCLAlertView.SCLAppearance(
                kButtonHeight: 50,
                kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
                kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
                kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
                
            )
            let alert = SCLAlertView(appearance: appearance)
            
            let textField = alert.addTextField("Enter new list name")
            textField.autocapitalizationType = .none
            
            alert.addButton("Update") {
                //check that a name has been introduced in textfield
                if textField.text != "" {
                    //first check if the user has another list with that name
                    if self.checkListExist(listName: textField.text!) {
                        //create alert saying that that list name already exists for the user
                        createWarningAlert(title: "List exists", subtitle: "There is another list with that name. Chose a different name")
                        self.tableView.reloadData()
                    } else {
                        if let list = self.lists?[indexPath.row] {
                            do{
                                try self.realm.write {
                                    list.name = (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
                                    list.name = textField.text!
                                }
                            } catch {
                                print("Error updating list \(error)")
                            }
                        }
                        
                        self.tableView.reloadData()
                        //notify to NotificacionCenter when data has changed
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
                    }
                    
                } else {
                    self.tableView.reloadData()
                }
                
            }

            let colorAlert = UIColor(named: "colorAlertEdit")
            let iconAlert = UIImage(named: "edit-icon")
            
            alert.showCustom("Update", subTitle: "Update the name of the list", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
            
            textField.delegate = self
            
        }
        
    }
    
    //MARK: Navigation Methods
    
    func startShowcase() {
        
        showcaseAddButton.setTargetView(barButtonItem: addButton)
        showcaseAddButton.primaryText = "Add Button"
        showcaseAddButton.secondaryText = "Click here to create a new list of sight words"
        
        designShowcase(showcase: showcaseAddButton)
        showcaseAddButton.delegate = self
        
        if (lists?.count)! > 0 {
            
            showcaseListRow.setTargetView(tableView: tableView, section: 0, row: 0)
            showcaseListRow.primaryText = "List of sight words"
            showcaseListRow.secondaryText = "Tap on it to see the sight words.\nSwipe it to the left to Edit or Delete the list."
            
            designShowcase(showcase: showcaseListRow)
            showcaseListRow.delegate = self
            sequenceShowcases.temp(showcaseAddButton).temp(showcaseListRow).start()
            
        } else {
            showcaseAddButton.show {
                
            }
        }
        
    }
    
    func createDefaultListAlert() {
        
        var hasAllDefaultList = true
        
        let appearance = SCLAlertView.SCLAppearance(
            kButtonHeight: 50,
            kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
            kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
            kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
            
        )
        let alert = SCLAlertView(appearance: appearance)
        let colorAlert = UIColor(named: "colorAlertEdit")
        let iconAlert = UIImage(named: "icon-list")
        
        if !checkListExist(listName: "Pre-K List") {
            alert.addButton("Pre-K List") {
                self.createPreKList(user: self.selectedUser!)
                //we call loadLists to reload the tableview and update lastListColor
                self.loadLists()
            }
            hasAllDefaultList = false
        }
        
        if !checkListExist(listName: "Kindergarten List") {
            alert.addButton("Kindergarten List") {
                self.createKindergartenList(user: self.selectedUser!)
                //we call loadLists to reload the tableview and update lastListColor
                self.loadLists()
            }
            hasAllDefaultList = false
        }
        
        if !checkListExist(listName: "First Grade List") {
            alert.addButton("First Grade List") {
                self.createFirstGradeList(user: self.selectedUser!)
                //we call loadLists to reload the tableview and update lastListColor
                self.loadLists()
            }
            hasAllDefaultList = false
        }
        
        if !checkListExist(listName: "Second Grade List") {
            alert.addButton("Second Grade List") {
                self.createSecondGradeList(user: self.selectedUser!)
                //we call loadLists to reload the tableview and update lastListColor
                self.loadLists()
            }
            hasAllDefaultList = false
        }
        
        if !checkListExist(listName: "Third Grade List") {
            alert.addButton("Third Grade List") {
                self.createThirdGradeList(user: self.selectedUser!)
                //we call loadLists to reload the tableview and update lastListColor
                self.loadLists()
            }
            hasAllDefaultList = false
        }

        if hasAllDefaultList == true {
            self.createAddListAlert()
        } else {
            alert.addButton("My own List") {
                self.createAddListAlert()
            }
            
            alert.showCustom("Preloaded List", subTitle: "Would you like to create a preloaded list?", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
        }
        
        
    }
    
    func createAddListAlert() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kButtonHeight: 50,
            kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
            kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
            kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
            
        )
        let alert = SCLAlertView(appearance: appearance)
        
        let textField = alert.addTextField("Enter list name")
        textField.autocapitalizationType = .none
        
        alert.addButton("Create") {
            
            //check that a name has been introduced in textfield
            if textField.text != "" {
                
                //first check if the user has another list with that name
                if self.checkListExist(listName: textField.text!) {
                    //create alert saying that that list name already exists for the user
                    createWarningAlert(title: "List exists", subtitle: "There is another list with that name. Chose a different name")
                    self.tableView.reloadData()
                } else {
                    //create the new list
                    if let currentUser = self.selectedUser {
                        
                        do {
                            try self.realm.write {
                                let newList = SightWordsList()
                                newList.name = (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
                                //create a different color than last
                                newList.color = UIColor.init(randomFlatColorExcludingColorsIn: [UIColor(hexString: self.lastListColor)!, UIColor.flatWhite]).hexValue()
                                currentUser.userLists.append(newList)
                            }
                        } catch {
                            print("Error saving list \(error)")
                        }
                        
                    }
                    
                    //we call loadLists to reload the tableview and update lastListColor
                    self.loadLists()
                    //notify to NotificacionCenter when data has changed
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
                }
            }
            
            
        }
        
        let colorAlert = UIColor(named: "colorAlertEdit")
        let iconAlert = UIImage(named: "icon-list")
        
        alert.showCustom("Create", subTitle: "Create a new list", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
        
        textField.delegate = self
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSingleListEditVC" {
            let destinationVC = segue.destination as! SingleListEditViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedList = self.lists?[indexPath.row]
                destinationVC.selectedUser = (selectedUser?.name)!
            }
        }
        
    }
    
    
    //MARK: Material Showcase Delegate Methods
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    //MARK: TextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 20
        
    }

    //MARK: - Default list methods
    
    public func createPreKList(user : User) {
        
        let listPreK = SightWordsList()
        
        //add list
        do {
            try realm.write {
                listPreK.name = "Pre-K List"
                listPreK.color = UIColor.randomFlat.hexValue()
                user.userLists.append(listPreK)
            }
        } catch {
            print("Error saving Pre-K list \(error)")
        }
        
        //add sight words
        do {
            try realm.write {
                let sightWord1 = SightWord()
                sightWord1.name = "a"
                sightWord1.index = 0
                sightWord1.userName = user.name
                listPreK.sightWords.append(sightWord1)
                let sightWord2 = SightWord()
                sightWord2.name = "and"
                sightWord2.index = 0
                sightWord2.userName = user.name
                listPreK.sightWords.append(sightWord2)
                let sightWord3 = SightWord()
                sightWord3.name = "away"
                sightWord3.index = 0
                sightWord3.userName = user.name
                listPreK.sightWords.append(sightWord3)
                let sightWord4 = SightWord()
                sightWord4.name = "big"
                sightWord4.index = 0
                sightWord4.userName = user.name
                listPreK.sightWords.append(sightWord4)
                let sightWord5 = SightWord()
                sightWord5.name = "blue"
                sightWord5.index = 0
                sightWord5.userName = user.name
                listPreK.sightWords.append(sightWord5)
                let sightWord6 = SightWord()
                sightWord6.name = "can"
                sightWord6.index = 0
                sightWord6.userName = user.name
                listPreK.sightWords.append(sightWord6)
                let sightWord7 = SightWord()
                sightWord7.name = "come"
                sightWord7.index = 0
                sightWord7.userName = user.name
                listPreK.sightWords.append(sightWord7)
                let sightWord8 = SightWord()
                sightWord8.name = "down"
                sightWord8.index = 0
                sightWord8.userName = user.name
                listPreK.sightWords.append(sightWord8)
                let sightWord9 = SightWord()
                sightWord9.name = "find"
                sightWord9.index = 0
                sightWord9.userName = user.name
                listPreK.sightWords.append(sightWord9)
                let sightWord10 = SightWord()
                sightWord10.name = "for"
                sightWord10.index = 0
                sightWord10.userName = user.name
                listPreK.sightWords.append(sightWord10)
                let sightWord11 = SightWord()
                sightWord11.name = "funny"
                sightWord11.index = 0
                sightWord11.userName = user.name
                listPreK.sightWords.append(sightWord11)
                let sightWord12 = SightWord()
                sightWord12.name = "go"
                sightWord12.index = 0
                sightWord12.userName = user.name
                listPreK.sightWords.append(sightWord12)
                let sightWord13 = SightWord()
                sightWord13.name = "help"
                sightWord13.index = 0
                sightWord13.userName = user.name
                listPreK.sightWords.append(sightWord13)
                let sightWord14 = SightWord()
                sightWord14.name = "here"
                sightWord14.index = 0
                sightWord14.userName = user.name
                listPreK.sightWords.append(sightWord14)
                let sightWord15 = SightWord()
                sightWord15.name = "in"
                sightWord15.index = 0
                sightWord15.userName = user.name
                listPreK.sightWords.append(sightWord15)
                let sightWord16 = SightWord()
                sightWord16.name = "is"
                sightWord16.index = 0
                sightWord16.userName = user.name
                listPreK.sightWords.append(sightWord16)
                let sightWord17 = SightWord()
                sightWord17.name = "it"
                sightWord17.index = 0
                sightWord17.userName = user.name
                listPreK.sightWords.append(sightWord17)
                let sightWord18 = SightWord()
                sightWord18.name = "I"
                sightWord18.index = 0
                sightWord18.userName = user.name
                listPreK.sightWords.append(sightWord18)
                let sightWord19 = SightWord()
                sightWord19.name = "jump"
                sightWord19.index = 0
                sightWord19.userName = user.name
                listPreK.sightWords.append(sightWord19)
                let sightWord20 = SightWord()
                sightWord20.name = "little"
                sightWord20.index = 0
                sightWord20.userName = user.name
                listPreK.sightWords.append(sightWord20)
                let sightWord21 = SightWord()
                sightWord21.name = "look"
                sightWord21.index = 0
                sightWord21.userName = user.name
                listPreK.sightWords.append(sightWord21)
                let sightWord22 = SightWord()
                sightWord22.name = "make"
                sightWord22.index = 0
                sightWord22.userName = user.name
                listPreK.sightWords.append(sightWord22)
                let sightWord23 = SightWord()
                sightWord23.name = "me"
                sightWord23.index = 0
                sightWord23.userName = user.name
                listPreK.sightWords.append(sightWord23)
                let sightWord24 = SightWord()
                sightWord24.name = "my"
                sightWord24.index = 0
                sightWord24.userName = user.name
                listPreK.sightWords.append(sightWord24)
                let sightWord25 = SightWord()
                sightWord25.name = "not"
                sightWord25.index = 0
                sightWord25.userName = user.name
                listPreK.sightWords.append(sightWord25)
                let sightWord26 = SightWord()
                sightWord26.name = "one"
                sightWord26.index = 0
                sightWord26.userName = user.name
                listPreK.sightWords.append(sightWord26)
                let sightWord27 = SightWord()
                sightWord27.name = "play"
                sightWord27.index = 0
                sightWord27.userName = user.name
                listPreK.sightWords.append(sightWord27)
                let sightWord28 = SightWord()
                sightWord28.name = "red"
                sightWord28.index = 0
                sightWord28.userName = user.name
                listPreK.sightWords.append(sightWord28)
                let sightWord29 = SightWord()
                sightWord29.name = "run"
                sightWord29.index = 0
                sightWord29.userName = user.name
                listPreK.sightWords.append(sightWord29)
                let sightWord30 = SightWord()
                sightWord30.name = "said"
                sightWord30.index = 0
                sightWord30.userName = user.name
                listPreK.sightWords.append(sightWord30)
                let sightWord31 = SightWord()
                sightWord31.name = "see"
                sightWord31.index = 0
                sightWord31.userName = user.name
                listPreK.sightWords.append(sightWord31)
                let sightWord32 = SightWord()
                sightWord32.name = "the"
                sightWord32.index = 0
                sightWord32.userName = user.name
                listPreK.sightWords.append(sightWord32)
                let sightWord33 = SightWord()
                sightWord33.name = "three"
                sightWord33.index = 0
                sightWord33.userName = user.name
                listPreK.sightWords.append(sightWord33)
                let sightWord34 = SightWord()
                sightWord34.name = "to"
                sightWord34.index = 0
                sightWord34.userName = user.name
                listPreK.sightWords.append(sightWord34)
                let sightWord35 = SightWord()
                sightWord35.name = "two"
                sightWord35.index = 0
                sightWord35.userName = user.name
                listPreK.sightWords.append(sightWord35)
                let sightWord36 = SightWord()
                sightWord36.name = "up"
                sightWord36.index = 0
                sightWord36.userName = user.name
                listPreK.sightWords.append(sightWord36)
                let sightWord37 = SightWord()
                sightWord37.name = "we"
                sightWord37.index = 0
                sightWord37.userName = user.name
                listPreK.sightWords.append(sightWord37)
                let sightWord38 = SightWord()
                sightWord38.name = "where"
                sightWord38.index = 0
                sightWord38.userName = user.name
                listPreK.sightWords.append(sightWord38)
                let sightWord39 = SightWord()
                sightWord39.name = "yellow"
                sightWord39.index = 0
                sightWord39.userName = user.name
                listPreK.sightWords.append(sightWord39)
                let sightWord40 = SightWord()
                sightWord40.name = "you"
                sightWord40.index = 0
                sightWord40.userName = user.name
                listPreK.sightWords.append(sightWord40)
            }
        } catch {
            print("Error saving word \(error)")
        }
        
        //notify to NotificacionCenter when data has changed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
        
    }
    
    public func createKindergartenList(user : User) {
        
        let listKindergarten = SightWordsList()
        
        //add list
        do {
            try self.realm.write {
                listKindergarten.name = "Kindergarten List"
                listKindergarten.color = UIColor.randomFlat.hexValue()
                user.userLists.append(listKindergarten)
            }
        } catch {
            print("Error saving Kindergarten list \(error)")
        }
        print("list saved")
        //add sight words
        do {
            try self.realm.write {
                let sightWord1 = SightWord()
                sightWord1.name = "all"
                sightWord1.index = 0
                sightWord1.userName = user.name
                listKindergarten.sightWords.append(sightWord1)
                let sightWord2 = SightWord()
                sightWord2.name = "am"
                sightWord2.index = 0
                sightWord2.userName = user.name
                listKindergarten.sightWords.append(sightWord2)
                let sightWord3 = SightWord()
                sightWord3.name = "are"
                sightWord3.index = 0
                sightWord3.userName = user.name
                listKindergarten.sightWords.append(sightWord3)
                let sightWord4 = SightWord()
                sightWord4.name = "at"
                sightWord4.index = 0
                sightWord4.userName = user.name
                listKindergarten.sightWords.append(sightWord4)
                let sightWord5 = SightWord()
                sightWord5.name = "ate"
                sightWord5.index = 0
                sightWord5.userName = user.name
                listKindergarten.sightWords.append(sightWord5)
                let sightWord6 = SightWord()
                sightWord6.name = "be"
                sightWord6.index = 0
                sightWord6.userName = user.name
                listKindergarten.sightWords.append(sightWord6)
                let sightWord7 = SightWord()
                sightWord7.name = "black"
                sightWord7.index = 0
                sightWord7.userName = user.name
                listKindergarten.sightWords.append(sightWord7)
                let sightWord8 = SightWord()
                sightWord8.name = "brown"
                sightWord8.index = 0
                sightWord8.userName = user.name
                listKindergarten.sightWords.append(sightWord8)
                let sightWord9 = SightWord()
                sightWord9.name = "but"
                sightWord9.index = 0
                sightWord9.userName = user.name
                listKindergarten.sightWords.append(sightWord9)
                let sightWord10 = SightWord()
                sightWord10.name = "came"
                sightWord10.index = 0
                sightWord10.userName = user.name
                listKindergarten.sightWords.append(sightWord10)
                let sightWord11 = SightWord()
                sightWord11.name = "did"
                sightWord11.index = 0
                sightWord11.userName = user.name
                listKindergarten.sightWords.append(sightWord11)
                let sightWord12 = SightWord()
                sightWord12.name = "do"
                sightWord12.index = 0
                sightWord12.userName = user.name
                listKindergarten.sightWords.append(sightWord12)
                let sightWord13 = SightWord()
                sightWord13.name = "eat"
                sightWord13.index = 0
                sightWord13.userName = user.name
                listKindergarten.sightWords.append(sightWord13)
                let sightWord14 = SightWord()
                sightWord14.name = "for"
                sightWord14.index = 0
                sightWord14.userName = user.name
                listKindergarten.sightWords.append(sightWord14)
                let sightWord15 = SightWord()
                sightWord15.name = "get"
                sightWord15.index = 0
                sightWord15.userName = user.name
                listKindergarten.sightWords.append(sightWord15)
                let sightWord16 = SightWord()
                sightWord16.name = "good"
                sightWord16.index = 0
                sightWord16.userName = user.name
                listKindergarten.sightWords.append(sightWord16)
                let sightWord17 = SightWord()
                sightWord17.name = "have"
                sightWord17.index = 0
                sightWord17.userName = user.name
                listKindergarten.sightWords.append(sightWord17)
                let sightWord18 = SightWord()
                sightWord18.name = "he"
                sightWord18.index = 0
                sightWord18.userName = user.name
                listKindergarten.sightWords.append(sightWord18)
                let sightWord19 = SightWord()
                sightWord19.name = "into"
                sightWord19.index = 0
                sightWord19.userName = user.name
                listKindergarten.sightWords.append(sightWord19)
                let sightWord20 = SightWord()
                sightWord20.name = "like"
                sightWord20.index = 0
                sightWord20.userName = user.name
                listKindergarten.sightWords.append(sightWord20)
                let sightWord21 = SightWord()
                sightWord21.name = "must"
                sightWord21.index = 0
                sightWord21.userName = user.name
                listKindergarten.sightWords.append(sightWord21)
                let sightWord22 = SightWord()
                sightWord22.name = "new"
                sightWord22.index = 0
                sightWord22.userName = user.name
                listKindergarten.sightWords.append(sightWord22)
                let sightWord23 = SightWord()
                sightWord23.name = "no"
                sightWord23.index = 0
                sightWord23.userName = user.name
                listKindergarten.sightWords.append(sightWord23)
                let sightWord24 = SightWord()
                sightWord24.name = "now"
                sightWord24.index = 0
                sightWord24.userName = user.name
                listKindergarten.sightWords.append(sightWord24)
                let sightWord25 = SightWord()
                sightWord25.name = "on"
                sightWord25.index = 0
                sightWord25.userName = user.name
                listKindergarten.sightWords.append(sightWord25)
                let sightWord26 = SightWord()
                sightWord26.name = "our"
                sightWord26.index = 0
                sightWord26.userName = user.name
                listKindergarten.sightWords.append(sightWord26)
                let sightWord27 = SightWord()
                sightWord27.name = "out"
                sightWord27.index = 0
                sightWord27.userName = user.name
                listKindergarten.sightWords.append(sightWord27)
                let sightWord28 = SightWord()
                sightWord28.name = "please"
                sightWord28.index = 0
                sightWord28.userName = user.name
                listKindergarten.sightWords.append(sightWord28)
                let sightWord29 = SightWord()
                sightWord29.name = "pretty"
                sightWord29.index = 0
                sightWord29.userName = user.name
                listKindergarten.sightWords.append(sightWord29)
                let sightWord30 = SightWord()
                sightWord30.name = "ran"
                sightWord30.index = 0
                sightWord30.userName = user.name
                listKindergarten.sightWords.append(sightWord30)
                let sightWord31 = SightWord()
                sightWord31.name = "ride"
                sightWord31.index = 0
                sightWord31.userName = user.name
                listKindergarten.sightWords.append(sightWord31)
                let sightWord32 = SightWord()
                sightWord32.name = "saw"
                sightWord32.index = 0
                sightWord32.userName = user.name
                listKindergarten.sightWords.append(sightWord32)
                let sightWord33 = SightWord()
                sightWord33.name = "say"
                sightWord33.index = 0
                sightWord33.userName = user.name
                listKindergarten.sightWords.append(sightWord33)
                let sightWord34 = SightWord()
                sightWord34.name = "she"
                sightWord34.index = 0
                sightWord34.userName = user.name
                listKindergarten.sightWords.append(sightWord34)
                let sightWord35 = SightWord()
                sightWord35.name = "so"
                sightWord35.index = 0
                sightWord35.userName = user.name
                listKindergarten.sightWords.append(sightWord35)
                let sightWord36 = SightWord()
                sightWord36.name = "soon"
                sightWord36.index = 0
                sightWord36.userName = user.name
                listKindergarten.sightWords.append(sightWord36)
                let sightWord37 = SightWord()
                sightWord37.name = "that"
                sightWord37.index = 0
                sightWord37.userName = user.name
                listKindergarten.sightWords.append(sightWord37)
                let sightWord38 = SightWord()
                sightWord38.name = "there"
                sightWord38.index = 0
                sightWord38.userName = user.name
                listKindergarten.sightWords.append(sightWord38)
                let sightWord39 = SightWord()
                sightWord39.name = "they"
                sightWord39.index = 0
                sightWord39.userName = user.name
                listKindergarten.sightWords.append(sightWord39)
                let sightWord40 = SightWord()
                sightWord40.name = "this"
                sightWord40.index = 0
                sightWord40.userName = user.name
                listKindergarten.sightWords.append(sightWord40)
                let sightWord41 = SightWord()
                sightWord41.name = "too"
                sightWord41.index = 0
                sightWord41.userName = user.name
                listKindergarten.sightWords.append(sightWord41)
                let sightWord42 = SightWord()
                sightWord42.name = "under"
                sightWord42.index = 0
                sightWord42.userName = user.name
                listKindergarten.sightWords.append(sightWord42)
                let sightWord43 = SightWord()
                sightWord43.name = "want"
                sightWord43.index = 0
                sightWord43.userName = user.name
                listKindergarten.sightWords.append(sightWord43)
                let sightWord44 = SightWord()
                sightWord44.name = "was"
                sightWord44.index = 0
                sightWord44.userName = user.name
                listKindergarten.sightWords.append(sightWord44)
                let sightWord45 = SightWord()
                sightWord45.name = "well"
                sightWord45.index = 0
                sightWord45.userName = user.name
                listKindergarten.sightWords.append(sightWord45)
                let sightWord46 = SightWord()
                sightWord46.name = "went"
                sightWord46.index = 0
                sightWord46.userName = user.name
                listKindergarten.sightWords.append(sightWord46)
                let sightWord47 = SightWord()
                sightWord47.name = "what"
                sightWord47.index = 0
                sightWord47.userName = user.name
                listKindergarten.sightWords.append(sightWord47)
                let sightWord48 = SightWord()
                sightWord48.name = "white"
                sightWord48.index = 0
                sightWord48.userName = user.name
                listKindergarten.sightWords.append(sightWord48)
                let sightWord49 = SightWord()
                sightWord49.name = "who"
                sightWord49.index = 0
                sightWord49.userName = user.name
                listKindergarten.sightWords.append(sightWord49)
                let sightWord50 = SightWord()
                sightWord50.name = "will"
                sightWord50.index = 0
                sightWord50.userName = user.name
                listKindergarten.sightWords.append(sightWord50)
                let sightWord51 = SightWord()
                sightWord51.name = "with"
                sightWord51.index = 0
                sightWord51.userName = user.name
                listKindergarten.sightWords.append(sightWord51)
                let sightWord52 = SightWord()
                sightWord52.name = "yes"
                sightWord52.index = 0
                sightWord52.userName = user.name
                listKindergarten.sightWords.append(sightWord52)
            }
        } catch {
            print("Error saving word \(error)")
        }
        
        print("words saved")
        //notify to NotificacionCenter when data has changed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
        
    }
    
    public func createFirstGradeList(user : User) {
        
        let listFirstGrade = SightWordsList()
        
        //add list
        do {
            try realm.write {
                listFirstGrade.name = "First Grade List"
                listFirstGrade.color = UIColor.randomFlat.hexValue()
                user.userLists.append(listFirstGrade)
            }
        } catch {
            print("Error saving First Grade list \(error)")
        }
        
        //add sight words
        do {
            try realm.write {
                let sightWord1 = SightWord()
                sightWord1.name = "after"
                sightWord1.index = 0
                sightWord1.userName = user.name
                listFirstGrade.sightWords.append(sightWord1)
                let sightWord2 = SightWord()
                sightWord2.name = "again"
                sightWord2.index = 0
                sightWord2.userName = user.name
                listFirstGrade.sightWords.append(sightWord2)
                let sightWord3 = SightWord()
                sightWord3.name = "an"
                sightWord3.index = 0
                sightWord3.userName = user.name
                listFirstGrade.sightWords.append(sightWord3)
                let sightWord4 = SightWord()
                sightWord4.name = "any"
                sightWord4.index = 0
                sightWord4.userName = user.name
                listFirstGrade.sightWords.append(sightWord4)
                let sightWord5 = SightWord()
                sightWord5.name = "as"
                sightWord5.index = 0
                sightWord5.userName = user.name
                listFirstGrade.sightWords.append(sightWord5)
                let sightWord6 = SightWord()
                sightWord6.name = "ask"
                sightWord6.index = 0
                sightWord6.userName = user.name
                listFirstGrade.sightWords.append(sightWord6)
                let sightWord7 = SightWord()
                sightWord7.name = "by"
                sightWord7.index = 0
                sightWord7.userName = user.name
                listFirstGrade.sightWords.append(sightWord7)
                let sightWord8 = SightWord()
                sightWord8.name = "could"
                sightWord8.index = 0
                sightWord8.userName = user.name
                listFirstGrade.sightWords.append(sightWord8)
                let sightWord9 = SightWord()
                sightWord9.name = "every"
                sightWord9.index = 0
                sightWord9.userName = user.name
                listFirstGrade.sightWords.append(sightWord9)
                let sightWord10 = SightWord()
                sightWord10.name = "fly"
                sightWord10.index = 0
                sightWord10.userName = user.name
                listFirstGrade.sightWords.append(sightWord10)
                let sightWord11 = SightWord()
                sightWord11.name = "from"
                sightWord11.index = 0
                sightWord11.userName = user.name
                listFirstGrade.sightWords.append(sightWord11)
                let sightWord12 = SightWord()
                sightWord12.name = "give"
                sightWord12.index = 0
                sightWord12.userName = user.name
                listFirstGrade.sightWords.append(sightWord12)
                let sightWord13 = SightWord()
                sightWord13.name = "going"
                sightWord13.index = 0
                sightWord13.userName = user.name
                listFirstGrade.sightWords.append(sightWord13)
                let sightWord14 = SightWord()
                sightWord14.name = "had"
                sightWord14.index = 0
                sightWord14.userName = user.name
                listFirstGrade.sightWords.append(sightWord14)
                let sightWord15 = SightWord()
                sightWord15.name = "has"
                sightWord15.index = 0
                sightWord15.userName = user.name
                listFirstGrade.sightWords.append(sightWord15)
                let sightWord16 = SightWord()
                sightWord16.name = "her"
                sightWord16.index = 0
                sightWord16.userName = user.name
                listFirstGrade.sightWords.append(sightWord16)
                let sightWord17 = SightWord()
                sightWord17.name = "him"
                sightWord17.index = 0
                sightWord17.userName = user.name
                listFirstGrade.sightWords.append(sightWord17)
                let sightWord18 = SightWord()
                sightWord18.name = "his"
                sightWord18.index = 0
                sightWord18.userName = user.name
                listFirstGrade.sightWords.append(sightWord18)
                let sightWord19 = SightWord()
                sightWord19.name = "how"
                sightWord19.index = 0
                sightWord19.userName = user.name
                listFirstGrade.sightWords.append(sightWord19)
                let sightWord20 = SightWord()
                sightWord20.name = "just"
                sightWord20.index = 0
                sightWord20.userName = user.name
                listFirstGrade.sightWords.append(sightWord20)
                let sightWord21 = SightWord()
                sightWord21.name = "know"
                sightWord21.index = 0
                sightWord21.userName = user.name
                listFirstGrade.sightWords.append(sightWord21)
                let sightWord22 = SightWord()
                sightWord22.name = "let"
                sightWord22.index = 0
                sightWord22.userName = user.name
                listFirstGrade.sightWords.append(sightWord22)
                let sightWord23 = SightWord()
                sightWord23.name = "live"
                sightWord23.index = 0
                sightWord23.userName = user.name
                listFirstGrade.sightWords.append(sightWord23)
                let sightWord24 = SightWord()
                sightWord24.name = "may"
                sightWord24.index = 0
                sightWord24.userName = user.name
                listFirstGrade.sightWords.append(sightWord24)
                let sightWord25 = SightWord()
                sightWord25.name = "of"
                sightWord25.index = 0
                sightWord25.userName = user.name
                listFirstGrade.sightWords.append(sightWord25)
                let sightWord26 = SightWord()
                sightWord26.name = "one"
                sightWord26.index = 0
                sightWord26.userName = user.name
                listFirstGrade.sightWords.append(sightWord26)
                let sightWord27 = SightWord()
                sightWord27.name = "old"
                sightWord27.index = 0
                sightWord27.userName = user.name
                listFirstGrade.sightWords.append(sightWord27)
                let sightWord28 = SightWord()
                sightWord28.name = "once"
                sightWord28.index = 0
                sightWord28.userName = user.name
                listFirstGrade.sightWords.append(sightWord28)
                let sightWord29 = SightWord()
                sightWord29.name = "open"
                sightWord29.index = 0
                sightWord29.userName = user.name
                listFirstGrade.sightWords.append(sightWord29)
                let sightWord30 = SightWord()
                sightWord30.name = "over"
                sightWord30.index = 0
                sightWord30.userName = user.name
                listFirstGrade.sightWords.append(sightWord30)
                let sightWord31 = SightWord()
                sightWord31.name = "put"
                sightWord31.index = 0
                sightWord31.userName = user.name
                listFirstGrade.sightWords.append(sightWord31)
                let sightWord32 = SightWord()
                sightWord32.name = "round"
                sightWord32.index = 0
                sightWord32.userName = user.name
                listFirstGrade.sightWords.append(sightWord32)
                let sightWord33 = SightWord()
                sightWord33.name = "some"
                sightWord33.index = 0
                sightWord33.userName = user.name
                listFirstGrade.sightWords.append(sightWord33)
                let sightWord34 = SightWord()
                sightWord34.name = "stop"
                sightWord34.index = 0
                sightWord34.userName = user.name
                listFirstGrade.sightWords.append(sightWord34)
                let sightWord35 = SightWord()
                sightWord35.name = "take"
                sightWord35.index = 0
                sightWord35.userName = user.name
                listFirstGrade.sightWords.append(sightWord35)
                let sightWord36 = SightWord()
                sightWord36.name = "thank"
                sightWord36.index = 0
                sightWord36.userName = user.name
                listFirstGrade.sightWords.append(sightWord36)
                let sightWord37 = SightWord()
                sightWord37.name = "them"
                sightWord37.index = 0
                sightWord37.userName = user.name
                listFirstGrade.sightWords.append(sightWord37)
                let sightWord38 = SightWord()
                sightWord38.name = "then"
                sightWord38.index = 0
                sightWord38.userName = user.name
                listFirstGrade.sightWords.append(sightWord38)
                let sightWord39 = SightWord()
                sightWord39.name = "think"
                sightWord39.index = 0
                sightWord39.userName = user.name
                listFirstGrade.sightWords.append(sightWord39)
                let sightWord40 = SightWord()
                sightWord40.name = "walk"
                sightWord40.index = 0
                sightWord40.userName = user.name
                listFirstGrade.sightWords.append(sightWord40)
                let sightWord41 = SightWord()
                sightWord41.name = "were"
                sightWord41.index = 0
                sightWord41.userName = user.name
                listFirstGrade.sightWords.append(sightWord41)
                let sightWord42 = SightWord()
                sightWord42.name = "when"
                sightWord42.index = 0
                sightWord42.userName = user.name
                listFirstGrade.sightWords.append(sightWord42)
            }
        } catch {
            print("Error saving word \(error)")
        }
        
        //notify to NotificacionCenter when data has changed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
        
    }
    
    public func createSecondGradeList(user : User) {

        let listSecondGrade = SightWordsList()
        
        //add list
        do {
            try realm.write {
                listSecondGrade.name = "Second Grade List"
                listSecondGrade.color = UIColor.randomFlat.hexValue()
                user.userLists.append(listSecondGrade)
            }
        } catch {
            print("Error saving Second Grade list \(error)")
        }
        
        //add sight words
        do {
            try realm.write {
                let sightWord1 = SightWord()
                sightWord1.name = "always"
                sightWord1.index = 0
                sightWord1.userName = user.name
                listSecondGrade.sightWords.append(sightWord1)
                let sightWord2 = SightWord()
                sightWord2.name = "around"
                sightWord2.index = 0
                sightWord2.userName = user.name
                listSecondGrade.sightWords.append(sightWord2)
                let sightWord3 = SightWord()
                sightWord3.name = "because"
                sightWord3.index = 0
                sightWord3.userName = user.name
                listSecondGrade.sightWords.append(sightWord3)
                let sightWord4 = SightWord()
                sightWord4.name = "been"
                sightWord4.index = 0
                sightWord4.userName = user.name
                listSecondGrade.sightWords.append(sightWord4)
                let sightWord5 = SightWord()
                sightWord5.name = "before"
                sightWord5.index = 0
                sightWord5.userName = user.name
                listSecondGrade.sightWords.append(sightWord5)
                let sightWord6 = SightWord()
                sightWord6.name = "best"
                sightWord6.index = 0
                sightWord6.userName = user.name
                listSecondGrade.sightWords.append(sightWord6)
                let sightWord7 = SightWord()
                sightWord7.name = "both"
                sightWord7.index = 0
                sightWord7.userName = user.name
                listSecondGrade.sightWords.append(sightWord7)
                let sightWord8 = SightWord()
                sightWord8.name = "buy"
                sightWord8.index = 0
                sightWord8.userName = user.name
                listSecondGrade.sightWords.append(sightWord8)
                let sightWord9 = SightWord()
                sightWord9.name = "cold"
                sightWord9.index = 0
                sightWord9.userName = user.name
                listSecondGrade.sightWords.append(sightWord9)
                let sightWord10 = SightWord()
                sightWord10.name = "does"
                sightWord10.index = 0
                sightWord10.userName = user.name
                listSecondGrade.sightWords.append(sightWord10)
                let sightWord11 = SightWord()
                sightWord11.name = "don't"
                sightWord11.index = 0
                sightWord11.userName = user.name
                listSecondGrade.sightWords.append(sightWord11)
                let sightWord12 = SightWord()
                sightWord12.name = "fast"
                sightWord12.index = 0
                sightWord12.userName = user.name
                listSecondGrade.sightWords.append(sightWord12)
                let sightWord13 = SightWord()
                sightWord13.name = "first"
                sightWord13.index = 0
                sightWord13.userName = user.name
                listSecondGrade.sightWords.append(sightWord13)
                let sightWord14 = SightWord()
                sightWord14.name = "five"
                sightWord14.index = 0
                sightWord14.userName = user.name
                listSecondGrade.sightWords.append(sightWord14)
                let sightWord15 = SightWord()
                sightWord15.name = "found"
                sightWord15.index = 0
                sightWord15.userName = user.name
                listSecondGrade.sightWords.append(sightWord15)
                let sightWord16 = SightWord()
                sightWord16.name = "gave"
                sightWord16.index = 0
                sightWord16.userName = user.name
                listSecondGrade.sightWords.append(sightWord16)
                let sightWord17 = SightWord()
                sightWord17.name = "goes"
                sightWord17.index = 0
                sightWord17.userName = user.name
                listSecondGrade.sightWords.append(sightWord17)
                let sightWord18 = SightWord()
                sightWord18.name = "green"
                sightWord18.index = 0
                sightWord18.userName = user.name
                listSecondGrade.sightWords.append(sightWord18)
                let sightWord19 = SightWord()
                sightWord19.name = "its"
                sightWord19.index = 0
                sightWord19.userName = user.name
                listSecondGrade.sightWords.append(sightWord19)
                let sightWord20 = SightWord()
                sightWord20.name = "made"
                sightWord20.index = 0
                sightWord20.userName = user.name
                listSecondGrade.sightWords.append(sightWord20)
                let sightWord21 = SightWord()
                sightWord21.name = "many"
                sightWord21.index = 0
                sightWord21.userName = user.name
                listSecondGrade.sightWords.append(sightWord21)
                let sightWord22 = SightWord()
                sightWord22.name = "off"
                sightWord22.index = 0
                sightWord22.userName = user.name
                listSecondGrade.sightWords.append(sightWord22)
                let sightWord23 = SightWord()
                sightWord23.name = "or"
                sightWord23.index = 0
                sightWord23.userName = user.name
                listSecondGrade.sightWords.append(sightWord23)
                let sightWord24 = SightWord()
                sightWord24.name = "pull"
                sightWord24.index = 0
                sightWord24.userName = user.name
                listSecondGrade.sightWords.append(sightWord24)
                let sightWord25 = SightWord()
                sightWord25.name = "read"
                sightWord25.index = 0
                sightWord25.userName = user.name
                listSecondGrade.sightWords.append(sightWord25)
                let sightWord26 = SightWord()
                sightWord26.name = "right"
                sightWord26.index = 0
                sightWord26.userName = user.name
                listSecondGrade.sightWords.append(sightWord26)
                let sightWord27 = SightWord()
                sightWord27.name = "sing"
                sightWord27.index = 0
                sightWord27.userName = user.name
                listSecondGrade.sightWords.append(sightWord27)
                let sightWord28 = SightWord()
                sightWord28.name = "sit"
                sightWord28.index = 0
                sightWord28.userName = user.name
                listSecondGrade.sightWords.append(sightWord28)
                let sightWord29 = SightWord()
                sightWord29.name = "sleep"
                sightWord29.index = 0
                sightWord29.userName = user.name
                listSecondGrade.sightWords.append(sightWord29)
                let sightWord30 = SightWord()
                sightWord30.name = "tell"
                sightWord30.index = 0
                sightWord30.userName = user.name
                listSecondGrade.sightWords.append(sightWord30)
                let sightWord31 = SightWord()
                sightWord31.name = "their"
                sightWord31.index = 0
                sightWord31.userName = user.name
                listSecondGrade.sightWords.append(sightWord31)
                let sightWord32 = SightWord()
                sightWord32.name = "these"
                sightWord32.index = 0
                sightWord32.userName = user.name
                listSecondGrade.sightWords.append(sightWord32)
                let sightWord33 = SightWord()
                sightWord33.name = "those"
                sightWord33.index = 0
                sightWord33.userName = user.name
                listSecondGrade.sightWords.append(sightWord33)
                let sightWord34 = SightWord()
                sightWord34.name = "upon"
                sightWord34.index = 0
                sightWord34.userName = user.name
                listSecondGrade.sightWords.append(sightWord34)
                let sightWord35 = SightWord()
                sightWord35.name = "us"
                sightWord35.index = 0
                sightWord35.userName = user.name
                listSecondGrade.sightWords.append(sightWord35)
                let sightWord36 = SightWord()
                sightWord36.name = "use"
                sightWord36.index = 0
                sightWord36.userName = user.name
                listSecondGrade.sightWords.append(sightWord36)
                let sightWord37 = SightWord()
                sightWord37.name = "very"
                sightWord37.index = 0
                sightWord37.userName = user.name
                listSecondGrade.sightWords.append(sightWord37)
                let sightWord38 = SightWord()
                sightWord38.name = "wash"
                sightWord38.index = 0
                sightWord38.userName = user.name
                listSecondGrade.sightWords.append(sightWord38)
                let sightWord39 = SightWord()
                sightWord39.name = "which"
                sightWord39.index = 0
                sightWord39.userName = user.name
                listSecondGrade.sightWords.append(sightWord39)
                let sightWord40 = SightWord()
                sightWord40.name = "why"
                sightWord40.index = 0
                sightWord40.userName = user.name
                listSecondGrade.sightWords.append(sightWord40)
                let sightWord41 = SightWord()
                sightWord41.name = "wish"
                sightWord41.index = 0
                sightWord41.userName = user.name
                listSecondGrade.sightWords.append(sightWord41)
                let sightWord42 = SightWord()
                sightWord42.name = "work"
                sightWord42.index = 0
                sightWord42.userName = user.name
                listSecondGrade.sightWords.append(sightWord42)
                let sightWord43 = SightWord()
                sightWord43.name = "would"
                sightWord43.index = 0
                sightWord43.userName = user.name
                listSecondGrade.sightWords.append(sightWord43)
                let sightWord44 = SightWord()
                sightWord44.name = "write"
                sightWord44.index = 0
                sightWord44.userName = user.name
                listSecondGrade.sightWords.append(sightWord44)
                let sightWord45 = SightWord()
                sightWord45.name = "your"
                sightWord45.index = 0
                sightWord45.userName = user.name
                listSecondGrade.sightWords.append(sightWord45)
            }
        } catch {
            print("Error saving word \(error)")
        }
        
        //notify to NotificacionCenter when data has changed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
        
    }
    
    public func createThirdGradeList(user : User) {
        
        let listThirdGrade = SightWordsList()
        
        //add list
        do {
            try realm.write {
                //            list = SightWordsList()
                listThirdGrade.name = "Third Grade List"
                listThirdGrade.color = UIColor.randomFlat.hexValue()
                user.userLists.append(listThirdGrade)
            }
        } catch {
            print("Error saving Third Grade list \(error)")
        }
        
        //add sight words
        do {
            try realm.write {
                let sightWord1 = SightWord()
                sightWord1.name = "about"
                sightWord1.index = 0
                sightWord1.userName = user.name
                listThirdGrade.sightWords.append(sightWord1)
                let sightWord2 = SightWord()
                sightWord2.name = "better"
                sightWord2.index = 0
                sightWord2.userName = user.name
                listThirdGrade.sightWords.append(sightWord2)
                let sightWord3 = SightWord()
                sightWord3.name = "bring"
                sightWord3.index = 0
                sightWord3.userName = user.name
                listThirdGrade.sightWords.append(sightWord3)
                let sightWord4 = SightWord()
                sightWord4.name = "carry"
                sightWord4.index = 0
                sightWord4.userName = user.name
                listThirdGrade.sightWords.append(sightWord4)
                let sightWord5 = SightWord()
                sightWord5.name = "clean"
                sightWord5.index = 0
                sightWord5.userName = user.name
                listThirdGrade.sightWords.append(sightWord5)
                let sightWord6 = SightWord()
                sightWord6.name = "cut"
                sightWord6.index = 0
                sightWord6.userName = user.name
                listThirdGrade.sightWords.append(sightWord6)
                let sightWord7 = SightWord()
                sightWord7.name = "done"
                sightWord7.index = 0
                sightWord7.userName = user.name
                listThirdGrade.sightWords.append(sightWord7)
                let sightWord8 = SightWord()
                sightWord8.name = "draw"
                sightWord8.index = 0
                sightWord8.userName = user.name
                listThirdGrade.sightWords.append(sightWord8)
                let sightWord9 = SightWord()
                sightWord9.name = "drink"
                sightWord9.index = 0
                sightWord9.userName = user.name
                listThirdGrade.sightWords.append(sightWord9)
                let sightWord10 = SightWord()
                sightWord10.name = "eight"
                sightWord10.index = 0
                sightWord10.userName = user.name
                listThirdGrade.sightWords.append(sightWord10)
                let sightWord11 = SightWord()
                sightWord11.name = "fall"
                sightWord11.index = 0
                sightWord11.userName = user.name
                listThirdGrade.sightWords.append(sightWord11)
                let sightWord12 = SightWord()
                sightWord12.name = "far"
                sightWord12.index = 0
                sightWord12.userName = user.name
                listThirdGrade.sightWords.append(sightWord12)
                let sightWord13 = SightWord()
                sightWord13.name = "full"
                sightWord13.index = 0
                sightWord13.userName = user.name
                listThirdGrade.sightWords.append(sightWord13)
                let sightWord14 = SightWord()
                sightWord14.name = "got"
                sightWord14.index = 0
                sightWord14.userName = user.name
                listThirdGrade.sightWords.append(sightWord14)
                let sightWord15 = SightWord()
                sightWord15.name = "grow"
                sightWord15.index = 0
                sightWord15.userName = user.name
                listThirdGrade.sightWords.append(sightWord15)
                let sightWord16 = SightWord()
                sightWord16.name = "hold"
                sightWord16.index = 0
                sightWord16.userName = user.name
                listThirdGrade.sightWords.append(sightWord16)
                let sightWord17 = SightWord()
                sightWord17.name = "hot"
                sightWord17.index = 0
                sightWord17.userName = user.name
                listThirdGrade.sightWords.append(sightWord17)
                let sightWord18 = SightWord()
                sightWord18.name = "hurt"
                sightWord18.index = 0
                sightWord18.userName = user.name
                listThirdGrade.sightWords.append(sightWord18)
                let sightWord19 = SightWord()
                sightWord19.name = "if"
                sightWord19.index = 0
                sightWord19.userName = user.name
                listThirdGrade.sightWords.append(sightWord19)
                let sightWord20 = SightWord()
                sightWord20.name = "keep"
                sightWord20.index = 0
                sightWord20.userName = user.name
                listThirdGrade.sightWords.append(sightWord20)
                let sightWord21 = SightWord()
                sightWord21.name = "kind"
                sightWord21.index = 0
                sightWord21.userName = user.name
                listThirdGrade.sightWords.append(sightWord21)
                let sightWord22 = SightWord()
                sightWord22.name = "laugh"
                sightWord22.index = 0
                sightWord22.userName = user.name
                listThirdGrade.sightWords.append(sightWord22)
                let sightWord23 = SightWord()
                sightWord23.name = "light"
                sightWord23.index = 0
                sightWord23.userName = user.name
                listThirdGrade.sightWords.append(sightWord23)
                let sightWord24 = SightWord()
                sightWord24.name = "long"
                sightWord24.index = 0
                sightWord24.userName = user.name
                listThirdGrade.sightWords.append(sightWord24)
                let sightWord25 = SightWord()
                sightWord25.name = "much"
                sightWord25.index = 0
                sightWord25.userName = user.name
                listThirdGrade.sightWords.append(sightWord25)
                let sightWord26 = SightWord()
                sightWord26.name = "myself"
                sightWord26.index = 0
                sightWord26.userName = user.name
                listThirdGrade.sightWords.append(sightWord26)
                let sightWord27 = SightWord()
                sightWord27.name = "never"
                sightWord27.index = 0
                sightWord27.userName = user.name
                listThirdGrade.sightWords.append(sightWord27)
                let sightWord28 = SightWord()
                sightWord28.name = "only"
                sightWord28.index = 0
                sightWord28.userName = user.name
                listThirdGrade.sightWords.append(sightWord28)
                let sightWord29 = SightWord()
                sightWord29.name = "own"
                sightWord29.index = 0
                sightWord29.userName = user.name
                listThirdGrade.sightWords.append(sightWord29)
                let sightWord30 = SightWord()
                sightWord30.name = "pick"
                sightWord30.index = 0
                sightWord30.userName = user.name
                listThirdGrade.sightWords.append(sightWord30)
                let sightWord31 = SightWord()
                sightWord31.name = "seven"
                sightWord31.index = 0
                sightWord31.userName = user.name
                listThirdGrade.sightWords.append(sightWord31)
                let sightWord32 = SightWord()
                sightWord32.name = "shall"
                sightWord32.index = 0
                sightWord32.userName = user.name
                listThirdGrade.sightWords.append(sightWord32)
                let sightWord33 = SightWord()
                sightWord33.name = "show"
                sightWord33.index = 0
                sightWord33.userName = user.name
                listThirdGrade.sightWords.append(sightWord33)
                let sightWord34 = SightWord()
                sightWord34.name = "six"
                sightWord34.index = 0
                sightWord34.userName = user.name
                listThirdGrade.sightWords.append(sightWord34)
                let sightWord35 = SightWord()
                sightWord35.name = "small"
                sightWord35.index = 0
                sightWord35.userName = user.name
                listThirdGrade.sightWords.append(sightWord35)
                let sightWord36 = SightWord()
                sightWord36.name = "start"
                sightWord36.index = 0
                sightWord36.userName = user.name
                listThirdGrade.sightWords.append(sightWord36)
                let sightWord37 = SightWord()
                sightWord37.name = "ten"
                sightWord37.index = 0
                sightWord37.userName = user.name
                listThirdGrade.sightWords.append(sightWord37)
                let sightWord38 = SightWord()
                sightWord38.name = "today"
                sightWord38.index = 0
                sightWord38.userName = user.name
                listThirdGrade.sightWords.append(sightWord38)
                let sightWord39 = SightWord()
                sightWord39.name = "together"
                sightWord39.index = 0
                sightWord39.userName = user.name
                listThirdGrade.sightWords.append(sightWord39)
                let sightWord40 = SightWord()
                sightWord40.name = "try"
                sightWord40.index = 0
                sightWord40.userName = user.name
                listThirdGrade.sightWords.append(sightWord40)
                let sightWord41 = SightWord()
                sightWord41.name = "warm"
                sightWord41.index = 0
                sightWord41.userName = user.name
                listThirdGrade.sightWords.append(sightWord41)
            }
        } catch {
            print("Error saving word \(error)")
        }
        
        //notify to NotificacionCenter when data has changed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
        
    }

    
    //MARK - IBAction Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        createDefaultListAlert()
        
    }
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        
        if (lists?.count)! > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        
        startShowcase()
        
    }
    
}

