//
//  SwitchUserViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class SwitchUserViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    let realm = try! Realm()
    
    var lists : Results<SightWordsList>?
    var words : Results<SightWord>?
    
    var selectedUser : User? {
        didSet{
            //loadLists()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        updateUI()
        
    }


    // MARK: - Navigation

    func updateUI() {
        
//        logoutButton.layer.borderColor = FlatPlum().cgColor
//        logoutButton.layer.borderWidth = 1
//        logoutButton.layer.cornerRadius = 5
        
    }

    
     @IBAction func logoutButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToUsersVC", sender: self)
     }
    
}
