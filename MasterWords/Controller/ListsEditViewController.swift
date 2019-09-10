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
    
    var lists : Results<SightWordsList>?
//    var lists : List<SightWordsList>?
    
    var selectedUser : User? {
        didSet{
            loadLists()
        }
    }
    
    let sequenceShowcases = MaterialShowcaseSequence()
    let showcaseAddButton = MaterialShowcase()
    let showcaseListRow = MaterialShowcase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\(selectedUser!.name)'s Lists"
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        navigationItem.prompt = selectedUser?.name
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! SingleListEditViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedList = self.lists?[indexPath.row]
            destinationVC.selectedUser = (selectedUser?.name)!
        }
        
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
        
        print("In ListsEditVc - loadlists()")
        lists = selectedUser?.userLists.sorted(byKeyPath: "name", ascending: true)
//        lists = selectedUser?.userLists
        print(lists as Any)
        tableView.reloadData()
        
    }
    
//    override func updateModel(at indexPath: IndexPath, delete: Bool) {
//
//        if delete {
//            if let list = self.lists?[indexPath.row] {
//                do{
//                    try self.realm.write {
//                        self.realm.delete(list)
//                    }
//                } catch {
//                    print("Error deleting list \(error)")
//                }
//            }
//        } else {
//            var textField = UITextField()
//
//            let alert = UIAlertController(title: "Update", message: "", preferredStyle: .alert)
//
//            let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
//
//                if let list = self.lists?[indexPath.row] {
//                    do{
//                        try self.realm.write {
//                            list.name = textField.text!
//                        }
//                    } catch {
//                        print("Error updating list \(error)")
//                    }
//                }
//
//                self.tableView.reloadData()
//                //notify to NotificacionCenter when data has changed
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
//            }
//
//            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
//                alert.dismiss(animated: true, completion: nil)
//            }
//
//            //we add a textfield to the UIalert
//            alert.addTextField { (alertTextField) in
//                alertTextField.placeholder = "New"
//                textField = alertTextField
//            }
//
//            //we add the action to the UIalert
//            alert.addAction(updateAction)
//            alert.addAction(cancelAction)
//
//            textField.delegate = self
//
//            present(alert, animated: true, completion: nil)
//
//        }
//
//    }
    
    override func updateModel(at indexPath: IndexPath, delete: Bool) {
        
        if delete {
            if let list = self.lists?[indexPath.row] {
                do{
                    try self.realm.write {
                        self.realm.delete(list)
                    }
                } catch {
                    print("Error deleting list \(error)")
                }
            }
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
                if let list = self.lists?[indexPath.row] {
                    do{
                        try self.realm.write {
                            list.name = textField.text!
                        }
                    } catch {
                        print("Error updating list \(error)")
                    }
                }
                
                self.tableView.reloadData()
                //notify to NotificacionCenter when data has changed
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
            }

            let colorAlert = UIColor(named: "colorAlertEdit")
            let iconAlert = UIImage(named: "edit-icon")
            
            alert.showCustom("Update", subTitle: "Update the name of the list", color: colorAlert!, icon: iconAlert!)
            
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
    
    //MARK: Material Showcase Delegate Methods
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    //MARK: TextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("textfield delegate called")
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 15
        
    }

    
    //MARK - IBAction Methods
    
//    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
//
//        var textField = UITextField()
//
//
//        let alert = UIAlertController(title: "New List", message: "", preferredStyle: .alert)
//
//        let addAction = UIAlertAction(title: "Add List", style: .default) { (action) in
//
//            if let currentUser = self.selectedUser {
//                //print("user \(self.selectedUser?.name)")
//                do {
//                    try self.realm.write {
//                        let newList = SightWordsList()
//                        newList.name = textField.text!
//                        newList.color = UIColor.randomFlat.hexValue()
//                        currentUser.userLists.append(newList)
//                    }
//                } catch {
//                    print("Error saving word \(error)")
//                }
//
//            }
//
//            self.tableView.reloadData()
//            //notify to NotificacionCenter when data has changed
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//
//        //we add a textfield to the UIalert
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Create new list"
//            textField = alertTextField
//        }
//
//        //we add the action to the UIalert
//        alert.addAction(addAction)
//        alert.addAction(cancelAction)
//
//        textField.delegate = self
//
//        present(alert, animated: true, completion: nil)
//
//    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
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
            
            if let currentUser = self.selectedUser {
                //print("user \(self.selectedUser?.name)")
                do {
                    try self.realm.write {
                        let newList = SightWordsList()
                        newList.name = textField.text!
                        newList.color = UIColor.randomFlat.hexValue()
                        currentUser.userLists.append(newList)
                    }
                } catch {
                    print("Error saving word \(error)")
                }
                
            }
            
            self.tableView.reloadData()
            //notify to NotificacionCenter when data has changed
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        }
        
        let colorAlert = UIColor(named: "colorAlertEdit")
        let iconAlert = UIImage(named: "icon-list")
        
        alert.showCustom("Create", subTitle: "Create a new list", color: colorAlert!, icon: iconAlert!)
        
        textField.delegate = self
        
    }
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        
        startShowcase()
        
    }
    
}

