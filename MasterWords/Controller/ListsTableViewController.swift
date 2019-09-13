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
    
    var lists : Results<SightWordsList>?
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLists), name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        
        loadLists()
        
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
            print("Lista vacia")
            
            self.tableView.reloadData()
            
            //create alert
            let appearance = SCLAlertView.SCLAppearance(
                kButtonHeight: 50,
                kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
                kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
                kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
                
            )
            let alert = SCLAlertView(appearance: appearance)
            let colorAlert = UIColor(named: "colorAlertEdit")
            let iconAlert = UIImage(named: "icon-warning")

            alert.showCustom("List empty", subTitle: "Add some sight words to the list", color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
            
        } else {
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
        let destinationVC = segue.destination as! FlashCardsViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedList = self.lists?[indexPath.row]
        }

    }
    
    //MARK: - DB Methods
    
    func loadLists() {
        
        //lists = realm.objects(SightWordsList.self).sorted(byKeyPath: "name", ascending: true)
        lists = selectedUser?.userLists.sorted(byKeyPath: "name", ascending: true)

        tableView.reloadData()
        
    }
    
    //func to reload data when Lists have been added, updated or removed
    @objc func reloadLists(notification: NSNotification) {

        print("Reloading Lists")
        self.tableView.reloadData()
        
    }

    //MARK: IBAction Methods
    
    @IBAction func helpButtonTapped(_ sender: UIBarButtonItem) {
        
        startShowcase()
        
    }
    
}
