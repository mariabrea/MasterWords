//
//  SwitchUserViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import MaterialShowcase


class SwitchUserViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    let realm = try! Realm()
    
    var lists : Results<SightWordsList>?
    var words : Results<SightWord>?
    
    var selectedUser : User? {
        didSet{
            //loadLists()
        }
    }
    
    let showcaseLogoutButton = MaterialShowcase()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        updateUI()
        
    }

    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation Methods

    func startShowcase() {
        
        showcaseLogoutButton.setTargetView(view: logoutButton)
        showcaseLogoutButton.primaryText = "Logout Button"
        showcaseLogoutButton.secondaryText = "Click here to switch the user."
        
        designShowcase(showcase: showcaseLogoutButton, sizeHolder: "big")
        
        showcaseLogoutButton.show {
            
        }
        
    }
    
    func updateUI() {
        
        let helpImage = UIImage(named: "iconHelp")
        let helpImageTinted = helpImage?.withRenderingMode(.alwaysTemplate)
        helpButton.setImage(helpImageTinted, for: .normal)
        helpButton.tintColor = UIColor.white
        
        nameLabel.text = selectedUser?.name
        
    }

    // MARK: - IBAction Methods
    
     @IBAction func logoutButtonTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "unwindToUsersVC", sender: self)
     }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        
        startShowcase()
        
    }
}
