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

class SingleListEditViewController: SwipeTableViewController, MaterialShowcaseDelegate {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var helpButton: UIBarButtonItem!
    
    
    let realm = try! Realm()
  
    var wordsList : Results<SightWord>?
    
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
            
        } else {
            cell.textLabel?.text = "No words added"
        }

        return cell

    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    //MARK: DB Methods
    
    func loadSightWords() {
        
        wordsList = selectedList?.sightWords.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
        
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
        } else {
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Update", message: "", preferredStyle: .alert)
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
                
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
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            //we add a textfield to the UIalert
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "New"
                textField = alertTextField
            }
            
            //we add the action to the UIalert
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
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

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Sight Word", message: "", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in

            //we create a new object of type Item of the dstabase, and we fill its attributes

            if let currentList = self.selectedList {
                do {
                    try self.realm.write {
                        let newWord = SightWord()
                        newWord.name = textField.text!
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
            
        //we add a textfield to the UIalert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new sight word"
            textField = alertTextField
        }

        //we add the action to the UIalert
        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

    }

    
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        
        startShowcase()
        
    }

}
