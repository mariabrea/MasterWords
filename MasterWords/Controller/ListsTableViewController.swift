//
//  ListsTableViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/15/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import MaterialShowcase
import SCLAlertView

class ListsTableViewController: UITableViewController {

    @IBOutlet weak var helpButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    
    var needToRefresh = false
    
    var lists : List<SightWordsList>?
    var wordsList : Results<SightWord>?
    
    var selectedUser : User? {
        didSet{
            loadLists()
        }
    }

    let showcaseListRow = MaterialShowcase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "\(selectedUser!.name)'s Lists"
        
        //set observer to detetct when Lists have been added, updated or removed
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLists), name: NSNotification.Name(rawValue: "loadListsFlashCards"), object: nil)
        
        loadLists()
        
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
    
    // MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        if let list = lists?[indexPath.row]{
            
            cell.textLabel?.text  = list.name
            guard let listColor = UIColor(hexString: list.color) else {fatalError()}
            cell.backgroundColor = listColor
            cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: listColor, isFlat: true)
            cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)
            
        }
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //we check if the list has sight words to practice
        let selectedList = self.lists?[indexPath.row]
        wordsList = selectedList?.sightWords.sorted(byKeyPath: "name", ascending: true)

        if wordsList?.count == 0 {

            self.tableView.reloadData()
            
            createWarningAlert(title: "List empty", subtitle: "Add some sight words to the list")
            
        } else {
            let startPracticeTime = Double(CFAbsoluteTimeGetCurrent())
            defaults.set(startPracticeTime, forKey: .timeUserStartCardsPractice)
//            print("startPracticeTime: \(startPracticeTime)")
            performSegue(withIdentifier: "goToFlashCardsVC", sender: self)
        }
        
    }
    
    //MARK: Navigation Methods
    
    func startShowcase() {
        
        if (lists?.count)! > 0 {
            
            showcaseListRow.setTargetView(tableView: tableView, section: 0, row: 0)
            showcaseListRow.primaryText = "List of sight words"
            showcaseListRow.secondaryText = "Tap on it to practice all the sight words on the list."
            
            designShowcase(showcase: showcaseListRow)
            
            showcaseListRow.show {
                
            }
            
        }
        
    }
    
    // MARK: - Segue Methods
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFlashCardsVC" {
            let destinationVC = segue.destination as! FlashCardsViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedList = self.lists?[indexPath.row]
            }

        }
        
    }
    
    //MARK: - DB Methods
    
    func loadLists() {

        lists = selectedUser?.userLists

        tableView.reloadData()
        
    }
    
    //func to reload data when Lists have been added, updated or removed
    @objc func reloadLists(notification: NSNotification) {

//        print("ListsTableViewController reloading lists")
        self.tableView.reloadData()
        
    }

    //MARK: IBAction Methods
    
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        
        startShowcase()
        
    }
    
}
