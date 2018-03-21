//
//  SwitchUserViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import ChameleonFramework

class SwitchUserViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logoutButton.layer.borderColor = FlatPlum().cgColor
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.cornerRadius = 5
        
    }


    // MARK: - Navigation

     @IBAction func logoutButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToUsersVC", sender: self)
     }
    
}
