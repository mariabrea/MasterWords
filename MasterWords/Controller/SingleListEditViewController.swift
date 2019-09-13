//
//  SingleListEditViewController.swift
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

class SingleListEditViewController: SwipeTableViewController, MaterialShowcaseDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var helpButton: UIBarButtonItem!
    
    
    let realm = try! Realm()
  
    var wordsList : Results<SightWord>?
    var wordsCheck : Results<SightWord>?
    
    var selectedUser : String = ""
    var selectedList : SightWordsList? {
        didSet{
            loadSightWords()
        }
    }
    
    let sequenceShowcases = MaterialShowcaseSequence()
    let showcaseAddButton = MaterialShowcase()
    let showcaseSightWordRow = MaterialShowcase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedList?.name
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }

    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return wordsList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let sightWord = wordsList?[indexPath.row] {
            cell.textLabel?.text = sightWord.name
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(hexString: selectedList!.color)?.darken(byPercentage:0.1)
            } else {
                cell.backgroundColor = UIColor(hexString: selectedList!.color)?.lighten(byPercentage:0.1)
            }

            cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
            cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)
            
        } else {
            cell.textLabel?.text = "No words added"
        }

        return cell

    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    //MARK: TextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("textfield delegate called")
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 15
        
    }
    
    
    //MARK: DB Methods
    
    func loadSightWords() {
        
        wordsList = selectedList?.sightWords.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
        
    }
    
    //function to check is a Word name already exists for the list
    func checkWordExist(wordName: String) -> Bool {
        
        wordsCheck = selectedList?.sightWords.filter("name = %@", wordName)
        if wordsCheck?.count ?? 0 >= 1 {
            return true
        } else {
            return false
        }
        
    }
    
    
    override func updateModel(at indexPath: IndexPath, delete: Bool) {
        if delete {
            if let word = self.wordsList?[indexPath.row] {
                do{
                    try self.realm.write {
                        self.realm.delete(word)
                    }
                } catch {
                    print("Error deleting sight word \(error)")
                }
            }
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
            
            let textField = alert.addTextField("Enter new sight word")
            textField.autocapitalizationType = .none
            alert.addButton("Update") {
                
                if let word = self.wordsList?[indexPath.row] {
                    do{
                        try self.realm.write {
                            word.name = textField.text!
                        }
                    } catch {
                        print("Error updating word list \(error)")
                    }
                }
                
                self.tableView.reloadData()
            }
            
            let colorAlert = UIColor(named: "colorAlertEdit")
            let iconAlert = UIImage(named: "edit-icon")
            
            alert.showCustom("Update", subTitle: "Update the name of the sight word", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
            
            textField.delegate = self
            
        }
        
    }


    //MARK: Navigation Methods
    
    func startShowcase() {
        
        showcaseAddButton.setTargetView(barButtonItem: addButton)
        showcaseAddButton.primaryText = "Add Button"
        showcaseAddButton.secondaryText = "Click here to add a new sight word to the list"
        
        designShowcase(showcase: showcaseAddButton)
        showcaseAddButton.delegate = self
        
        if (wordsList?.count)! > 0 {
            
            showcaseSightWordRow.setTargetView(tableView: tableView, section: 0, row: 0)
            showcaseSightWordRow.primaryText = "Sight word"
            showcaseSightWordRow.secondaryText = "Swipe it to the left to Edit or Delete the sight word."
            
            designShowcase(showcase: showcaseSightWordRow)
            showcaseSightWordRow.delegate = self
            
            sequenceShowcases.temp(showcaseAddButton).temp(showcaseSightWordRow).start()
            
        } else {
            showcaseAddButton.show {
                
            }
        }

    }
    
    //MARK: Material Showcase Delegate Methods
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    //MARK - IBAction Methods
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kButtonHeight: 50,
            kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
            kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
            kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
            
        )
        let alert = SCLAlertView(appearance: appearance)
        
        let textField = alert.addTextField("Enter sight word")
        textField.autocapitalizationType = .none
        alert.addButton("Add") {
            //first we check if the word already exists in the list
            if self.checkWordExist(wordName: textField.text!.lowercased()) {
                //create alert saying that that word name already exists for the list
                let appearance = SCLAlertView.SCLAppearance(
                    kButtonHeight: 50,
                    kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
                    kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
                    kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
                    
                )
                let alert = SCLAlertView(appearance: appearance)
                let colorAlert = UIColor(named: "colorAlertEdit")
                let iconAlert = UIImage(named: "icon-warning")
                
                alert.showCustom("Word exists", subTitle: "The sight word already exists in this list.", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
            } else {
                //we add the word to the list
                //we create a new object of type Item of the database, and we fill its attributes
                if let currentList = self.selectedList {
                    do {
                        try self.realm.write {
                            let newWord = SightWord()
                            newWord.name = textField.text!.lowercased()
                            newWord.index = 0
                            newWord.userName = self.selectedUser
                            currentList.sightWords.append(newWord)
                        }
                    } catch {
                        print("Error saving word \(error)")
                    }
                    
                }
                
                self.tableView.reloadData()
            }
            
        }
        
        let colorAlert = UIColor(named: "colorAlertEdit")
        let iconAlert = UIImage(named: "icon-word")
        
        alert.showCustom("Add", subTitle: "Add a new sight word to the list", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
        
        textField.delegate = self
        
    }
    
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        
        startShowcase()
        
    }

}
