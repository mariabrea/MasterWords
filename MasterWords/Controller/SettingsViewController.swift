//
//  SettingsViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/16/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var audioSwitch: UISwitch!
    
    let defaults = UserDefaults()
    
    private let productURL = URL(string: "https://itunes.apple.com/app/id958625272")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
    }
    
    
    //MARK: - Navigation Methods
    
    func updateUI() {
        
        audioSwitch.setOn(defaults.bool(forKey: .audio)!, animated: false)
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            writeReview()
        } else if indexPath.row == 1 {
            share()
        }
    }
    
    private func writeReview() {
        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "write-review")
        ]
        
        guard let writeReviewURL = components?.url else {
            return
        }
        
        UIApplication.shared.open(writeReviewURL)
    }
    
    private func share() {
        let activityViewController = UIActivityViewController(activityItems: [productURL],applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)

        if let popOver = activityViewController.popoverPresentationController {
            popOver.sourceView = self.view
        }
    }
    
    @IBAction func audioSwitchTapped(_ sender: UISwitch) {
        
        if sender.isOn {
            defaults.set(true, forKey: "audio")
        } else {
            defaults.set(false, forKey: "audio")
        }
        
    }
    
    @IBAction func unwindToSettingsVC(segue: UIStoryboardSegue) {
        
    }
    
}
