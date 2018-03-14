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

class ListsEditViewController: SwipeTableViewController{

    let realm = try! Realm()
    
    var lists : Results<SightWordsList>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLists()
        
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
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
        
        lists = realm.objects(SightWordsList.self).sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
        
    }
    
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
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Update", message: "", preferredStyle: .alert)
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
                
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
    //MARK - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "New List", message: "", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add List", style: .default) { (action) in
            
            //we create a new object of type Item of the dstabase, and we fill its attributes
            let newList = SightWordsList()
            newList.name = textField.text!
            newList.color = UIColor.randomFlat().hexValue()

            self.save(list : newList)

            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }

        //we add a textfield to the UIalert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new list"
            textField = alertTextField
        }

        //we add the action to the UIalert
        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

    }
}

