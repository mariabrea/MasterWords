//
//  UserEditViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 8/27/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//


    import UIKit
    import RealmSwift
//    import ChameleonFramework

    class UserEditViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
        
//        @IBOutlet weak var logoutButton: UIButton!
        
        @IBOutlet weak var nameBarLabel: UILabel!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var imageLabel: UILabel!
        @IBOutlet weak var saveButton: UIButton!
        @IBOutlet weak var cancelButton: UIButton!
        @IBOutlet weak var imagePickerView: UIPickerView!
        @IBOutlet weak var avatarButton: UIButton!
        
        let userImages = ["Cool", "Crying", "Drooling", "Grumpy", "Happy", "Mad", "Scared", "Sick", "Silly", "Sleepy", "Smily"]
        let realm = try! Realm()
        
//        var lists : Results<SightWordsList>?
//        var words : Results<SightWord>?
        var wordsList : Results<SightWord>?
        
        
        var selectedUser : User? {
            didSet{
                //loadLists()
            }
        }
        
        var selectedAvatarName = ""
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            nameTextField.delegate = self
            
            updateUI()
            
        }
        
        //set the text of status bar light
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
//***********Picker View Methods*******************//
        
        // Sets number of columns in picker view
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return userImages.count
        }

        // This function sets the text of the picker view to the content of the "userImages" array
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return userImages[row]
        }
        
        // When user selects an option, this function will set the text of the text field to reflect
        // the selected option.
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
            
            switch userImages[row] {
            case "Cool":
                selectedAvatarName = "coolAvatar"
            case "Crying":
                selectedAvatarName = "cryingAvatar"
            case "Drooling":
                selectedAvatarName = "droolingAvatar"
            case "Grumpy":
                selectedAvatarName = "grumpyAvatar"
            case "Happy":
                selectedAvatarName = "happyAvatar"
            case "Mad":
                selectedAvatarName = "madAvatar"
            case "Scared":
                selectedAvatarName = "scaredAvatar"
            case "Sick":
                selectedAvatarName = "sickAvatar"
            case "Silly":
                selectedAvatarName = "sillyAvatar"
            case "Sleepy":
                selectedAvatarName = "sleepyAvatar"
            case "Smily":
                selectedAvatarName = "smilyAvatar"
            default:
                selectedAvatarName = "happyAvatar"
            }
            
            print(selectedAvatarName)

            avatarButton.setImage(UIImage(named: selectedAvatarName), for: .normal)
            
            //close the picker view once made a selection
            self.view.endEditing(true)
            imagePickerView.isHidden = true
            
        }
        
        
        //DB Methods
        
        func updateUser() {
            
            
            if let user = self.selectedUser {
                do{
                    try self.realm.write {
                        user.name = nameTextField.text!
                        if selectedAvatarName != "" {
                            user.avatar = selectedAvatarName
                        }
                    }
                } catch {
                    print("Error updating user \(error)")
                }
            }
            
        }
        
        func updateUserNameInSightWordsTable() {
            
            loadSightWords()
            
                do {
                    try self.realm.write {
                        wordsList?.setValue(nameTextField.text!, forKeyPath: "userName")
                    }
                } catch {
                    print("Error erasing values \(error)")
                }
            
        }
        
        func loadSightWords() {
            
            wordsList = realm.objects(SightWord.self).filter("userName = %@", selectedUser?.name as Any)
            
        }
        
        //MARK: - Navigation Methods
        
        func updateUI() {
            
            nameBarLabel.text = selectedUser?.name
            
            imagePickerView.isHidden = true
            
            nameTextField.text = selectedUser?.name
            avatarButton.setImage(UIImage(named: selectedUser!.avatar), for: .normal)
            
        }
        
        
        @IBAction func avatarButtonTapped(_ sender: UIButton) {
            imagePickerView.isHidden = false
        }
        
        @IBAction func saveButtonTapped(_ sender: UIButton) {
            
            updateUserNameInSightWordsTable()
            updateUser()
            
            
            performSegue(withIdentifier: "goToUsersVC", sender: self)
            
        }
        
        @IBAction func cancelButtonTapped(_ sender: UIButton) {
            
            print("Calling performSegue withIdentifier: unwindToUsersVC")
            performSegue(withIdentifier: "unwindToUsersVC", sender: self)
            
        }
        
        //UITextFieldDelegate Methods
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            nameTextField.resignFirstResponder()
            
            return true
            
        }
        
    
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            //spaces not allowed in textfield
            if (string == " ") {
                return false
            }
            return true
            
        }
//
    }
