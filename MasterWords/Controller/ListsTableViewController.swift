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

class ListsTableViewController: UITableViewController {

    let realm = try! Realm()
    
    
    var needToRefresh = false
    
    var lists : Results<SightWordsList>?
    
    var selectedUser : User? {
        didSet{
            loadLists()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set observer to detetct when Lists have been added, updated or removed
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLists), name: NSNotification.Name(rawValue: "loadLists"), object: nil)
        
        loadLists()
        
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationItem.prompt = selectedUser?.name
        if let navBar = self.navigationController?.navigationBar {
            navBar.barStyle = UIBarStyle.black
        }
    }

    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        if let list = lists?[indexPath.row]{
            
            //cell.textLabel?.text  = list.name
            cell.textLabel?.text  = list.name
            guard let listColor = UIColor(hexString: list.color) else {fatalError()}
            cell.backgroundColor = listColor
//            cell.textLabel?.textColor = ContrastColorOf(listColor, returnFlat: true)
            cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: listColor, isFlat: true)
            
        }
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToFlashCardsVC", sender: self)
    }
    

    
    // MARK: - Navigation

//    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
//        tableView.reloadData()
//    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FlashCardsViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedList = self.lists?[indexPath.row]
        }

    }
    
    //MARK: - Database Methods
    
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


}
