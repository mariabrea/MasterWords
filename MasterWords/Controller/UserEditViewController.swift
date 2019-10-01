//
//  UserEditViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 8/27/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//


    import UIKit
    import RealmSwift
    import MaterialShowcase
    import SCLAlertView

    class UserEditViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, MaterialShowcaseDelegate {
        
        @IBOutlet weak var nameBarLabel: UILabel!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var imageLabel: UILabel!
        @IBOutlet weak var saveButton: UIButton!
        @IBOutlet weak var cancelButton: UIButton!
        @IBOutlet weak var imagePickerView: UIPickerView!
        @IBOutlet weak var avatarButton: UIButton!
        @IBOutlet weak var helpButton: UIButton!
        
        var action = String()
        
        let userImages = ["coolAvatar", "cryingAvatar", "droolingAvatar", "grumpyAvatar", "happyAvatar", "madAvatar", "scaredAvatar", "sickAvatar", "sillyAvatar", "sleepyAvatar", "smilyAvatar"]
        let realm = try! Realm()
        
        var wordsList : Results<SightWord>?
        var users : Results<User>?
        
        var selectedUser : User? {
            didSet{
                //loadLists()
            }
        }
        
        var selectedAvatarName = ""
        
        let sequenceShowcases = MaterialShowcaseSequence()
        let showcaseNameTextField = MaterialShowcase()
        let showcaseImageAvatar = MaterialShowcase()
        let showcaseSaveButton = MaterialShowcase()
        let showcaseCancelButton = MaterialShowcase()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            nameTextField.delegate = self
            
            updateUI()
            
        }
        
        //set the text of status bar light
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        //MARK: Picker View Methods
        
        // Sets number of columns in picker view
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return userImages.count
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            
            return 100
            
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
            let userView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 100))
            
//                    userView.backgroundColor = UIColor.blue
            
            let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
//                    userImageView.backgroundColor = UIColor.red
            userImageView.contentMode = .scaleAspectFit
            userView.addSubview(userImageView)
            
            //        userImageView.image = UIImage(named: "coolAvatar")
            userImageView.image = UIImage(named: userImages[row])

//            in case the pickerView is not used the function didSelectRow won't be called, then we assign the avatar already has the user or the first avatar as a default value
            selectedAvatarName = selectedUser?.avatar ?? "coolAvatar"
 
            return userView
            
        }
        
        // When user selects an option, this function will set the text of the text field to reflect
        // the selected option.
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

            selectedAvatarName = userImages[row]
//            print("pickerView didSelectRow")
//            print("selectedAvatarName: \(selectedAvatarName)")
            avatarButton.setImage(UIImage(named: selectedAvatarName), for: .normal)
            
            //close the picker view once made a selection
            self.view.endEditing(true)
            imagePickerView.isHidden = true
            
        }
        
        
        //MARK: DB Methods
        func loadUsers(){
            
            users = realm.objects(User.self).sorted(byKeyPath: "name", ascending: true)
            
//            print(users?.count as Any)
//            print(users as Any)
            
        }
        
        func checkUserExist() -> Bool {
            
            users = realm.objects(User.self).filter("name = %@", nameTextField.text! as Any).sorted(byKeyPath: "name", ascending: true)
            if users?.count == 1 {
                return true
            } else {
                return false
            }
            
        }
        
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
        
        func createUser() {
 
//            print("createUser: \(nameTextField.text!) \(selectedAvatarName)")
            
            do {
                try self.realm.write {
                    let newUser = User()
                    newUser.name = nameTextField.text!
                    newUser.avatar = selectedAvatarName
                    realm.add(newUser)
                }
            } catch {
                print("Error creating user \(error)")
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
        
        func startShowcase() {
            
            showcaseNameTextField.setTargetView(view: nameTextField)
            showcaseNameTextField.primaryText = "Name of the user"
            showcaseNameTextField.secondaryText = "Write the name of the user you chose."
            
            designShowcase(showcase: showcaseNameTextField, sizeHolder: "big")
            showcaseNameTextField.delegate = self
            
            showcaseImageAvatar.setTargetView(view: avatarButton)
            showcaseImageAvatar.primaryText = "Image of the user"
            showcaseImageAvatar.secondaryText = "Click here to select an image for the user."
            
            designShowcase(showcase: showcaseImageAvatar, sizeHolder: "big")
            showcaseImageAvatar.delegate = self
            
            showcaseSaveButton.setTargetView(view: saveButton)
            showcaseSaveButton.primaryText = "Save Button"
            showcaseSaveButton.secondaryText = "click here to save the changes made."
            
            designShowcase(showcase: showcaseSaveButton, sizeHolder: "big")
            showcaseSaveButton.delegate = self
            
            showcaseCancelButton.setTargetView(view: cancelButton)
            showcaseCancelButton.primaryText = "Cancel Button"
            showcaseCancelButton.secondaryText = "Click here to cancel all the changes."
            
            designShowcase(showcase: showcaseCancelButton, sizeHolder: "big")
            showcaseCancelButton.delegate = self
            sequenceShowcases.temp(showcaseNameTextField).temp(showcaseImageAvatar).temp(showcaseSaveButton).temp(showcaseCancelButton).start()
  
        }
        
        
        func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
            sequenceShowcases.showCaseWillDismis()
        }
        
        func updateUI() {
            
            let helpImage = UIImage(named: "iconHelp")
            let helpImageTinted = helpImage?.withRenderingMode(.alwaysTemplate)
            helpButton.setImage(helpImageTinted, for: .normal)
            helpButton.tintColor = UIColor.white
            
            if self.action != "create" {
                nameBarLabel.text = selectedUser?.name
                nameTextField.text = selectedUser?.name
                avatarButton.setImage(UIImage(named: selectedUser!.avatar), for: .normal)
            }
            
            imagePickerView.isHidden = true
            
        }
        
        //MARK: IBAction Methods
        
        @IBAction func avatarButtonTapped(_ sender: UIButton) {
            imagePickerView.isHidden = false
        }
        
        @IBAction func saveButtonTapped(_ sender: UIButton) {
            
//            print("action: \(self.action)")
            
            if self.action == "create" {
                //check that there is no other user with the same name
                if checkUserExist() {
                    createWarningAlert(title: "User exists", subtitle: "The user already exists, choose a different user name")
                } else {

                    createUser()
                    self.action = ""
                    performSegue(withIdentifier: "goToUsersVC", sender: self)
                }
           
            } else {
                //if the name is changed check that there is no other user with that name
                if selectedUser?.name != nameTextField.text {
                    if checkUserExist() {
                        createWarningAlert(title: "User exists", subtitle: "The user already exists, choose a different user name")
                    } else {
                        updateUserNameInSightWordsTable()
                        updateUser()
                        selectedUser?.name == nameTextField.text
                        performSegue(withIdentifier: "goToListsTab", sender: self)
                    }
                } else {
                    updateUser()
                    performSegue(withIdentifier: "goToListsTab", sender: self)
                }
                
            }
            
        }
        
        @IBAction func cancelButtonTapped(_ sender: UIButton) {
            
            if self.action == "create" {
                self.action = ""
                performSegue(withIdentifier: "goToUsersVC", sender: self)
            } else {
                performSegue(withIdentifier: "goToListsTab", sender: self)
            }
            
        }
        
        @IBAction func helpButtonTapped(_ sender: UIButton) {
            
            startShowcase()
            
        }
        
        //MARK: UITextField Delegate Methods
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            nameTextField.resignFirstResponder()
            
            return true
            
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            //spaces not allowed in textfield
            if (string == " ") {
                return false
            } else {
                let currentText = textField.text ?? ""
                guard let stringRange = Range(range, in: currentText) else { return false }
                
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                
                return updatedText.count <= 10
            }
//            return true
            
        }

        
        //MARK: Segue Methods
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "goToListsTab" {
                let barViewControllers = segue.destination as! UITabBarController
                
                let destinationVC1 = barViewControllers.viewControllers![3] as! UserEditViewController
                destinationVC1.selectedUser = selectedUser
                
                let nav1 = barViewControllers.viewControllers![0] as! UINavigationController
                let destinationVC2 = nav1.topViewController as! ListsEditViewController
                destinationVC2.selectedUser = selectedUser
                
                let nav2 = barViewControllers.viewControllers![1] as! UINavigationController
                let destinationVC3 = nav2.topViewController as! ListsTableViewController
                destinationVC3.selectedUser = selectedUser
                
                let destinationVC4 = barViewControllers.viewControllers![2] as! GraphTableViewController
                destinationVC4.selectedUser = selectedUser
                
                let destinationVC5 = barViewControllers.viewControllers![4] as! SwitchUserViewController
                destinationVC5.selectedUser = selectedUser
                
            }
            
        }

    }
