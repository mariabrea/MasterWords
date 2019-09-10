//
//  GraphTableViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/19/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import MaterialShowcase
import SCLAlertView

class GraphTableViewCell: UITableViewCell {
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var correctCountLabel: UILabel!
    @IBOutlet weak var wrongCountLabel: UILabel!
    @IBOutlet weak var correctBar: UIView!
    @IBOutlet weak var wrongBar: UIView!
    @IBOutlet weak var barsView: UIView!

    
}

class GraphTableViewController: UITableViewController, MaterialShowcaseDelegate, UITextFieldDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var sortUpButton: UIButton!
    @IBOutlet weak var sortDownButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var eraseButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    let realm = try! Realm()
    
    var lists : Results<SightWordsList>?
    var words : Results<SightWord>?
    
    var selectedUser : User? {
        didSet{
            //loadLists()
        }
    }

    var wordsNoDuplicates = [Word]()
    
    let sequenceShowcases = MaterialShowcaseSequence()
    let showcaseAddButton = MaterialShowcase()
    let showcaseEraseButton = MaterialShowcase()
    let showcaseSortUpButton = MaterialShowcase()
    let showcaseSortDownButton = MaterialShowcase()
    let showcaseResultsRow = MaterialShowcase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //observer set to notice when Cancel button in FlashCards is tapped
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGraph), name: NSNotification.Name(rawValue: "loadGraph"), object: nil)
        
        loadWords()
        
        updateUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
    }
    
    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Database Methods
    
    func loadWords(){
        
        words = realm.objects(SightWord.self).filter("userName = %@", selectedUser?.name as Any).sorted(byKeyPath: "name", ascending: true)
        
        print(words as Any)
        
        if let numberRows = words?.count {
            if numberRows > 0 {
                
                let newWord = Word()
                newWord.name = words![0].name
                newWord.numberCorrect = words![0].numberCorrect
                newWord.numberWrong = words![0].numberWrong
                newWord.numberTotal = newWord.numberCorrect + newWord.numberWrong
                
                wordsNoDuplicates.append(newWord)
                
                for i in 1...numberRows-1 {
                    if words![i].name == words![i-1].name {
                        wordsNoDuplicates.last?.numberCorrect += words![i].numberCorrect
                        wordsNoDuplicates.last?.numberWrong += words![i].numberWrong
                        wordsNoDuplicates.last?.numberTotal = (wordsNoDuplicates.last?.numberCorrect)! + (wordsNoDuplicates.last?.numberWrong)!
                    } else {
                        let newWord = Word()
                        newWord.name = words![i].name
                        newWord.numberCorrect = words![i].numberCorrect
                        newWord.numberWrong = words![i].numberWrong
                        newWord.numberTotal = newWord.numberCorrect + newWord.numberWrong
                        wordsNoDuplicates.append(newWord)
                    }
                }
                
                //calculate percentages
                for word in wordsNoDuplicates{
                    let totalCount = word.numberWrong + word.numberCorrect
                    word.numberTotal = totalCount
                    if totalCount > 0{
                        word.percentageCorrect = Int(round((Double(word.numberCorrect)/Double(totalCount))*100))
                        word.percentageWrong = 100 - word.percentageCorrect
                    }
                }
                

            }
        }
        
        tableView.reloadData()
        
    }
    
    func addList(name : String, numberOfWords : Int) {
        
        if let currentUser = self.selectedUser {
            //print("user \(self.selectedUser?.name)")
            do {
                try self.realm.write {
                    let newList = SightWordsList()
                    newList.name = name
                    newList.color = UIColor.randomFlat.hexValue()
                    
                    for i in 0...numberOfWords-1 {
                        let newWord = SightWord()
                        newWord.name = wordsNoDuplicates[i].name
                        newWord.numberCorrect = 0
                        newWord.numberWrong = 0
                        newList.sightWords.append(newWord)
                    }
                    
                    currentUser.userLists.append(newList)
                }
            } catch {
                print("Error saving word \(error)")
            }
            
        }
        
    }
    
    func save(list : SightWordsList) {
        
        do {
            try realm.write {
                realm.add(list)
            }
        } catch {
            print("Error saving list \(error)")
        }
        
    }
    
    func eraseValues() {

        do {
            try realm.write {
                words?.setValue(0, forKeyPath: "numberCorrect")
                words?.setValue(0, forKeyPath: "numberWrong")
            }
        } catch {
            print("Error erasing values \(error)")
        }
        
    }
    
    
    //MARK: - Navigation Methods
    
    //func called to reload the data when cancel button in FlashCards is clicked
    @objc func reloadGraph(notification: NSNotification) {
        
        print("Reloading Graph")
        
        wordsNoDuplicates.removeAll()
        loadWords()
        self.tableView.reloadData()
        
    }

    func startShowcase() {
        
        showcaseAddButton.setTargetView(view: addButton)
        showcaseAddButton.primaryText = "Add Button"
        showcaseAddButton.secondaryText = "Click here to create a new list of sight words using the list of results"
        
        designShowcase(showcase: showcaseAddButton)
        
        showcaseEraseButton.setTargetView(view: eraseButton)
        showcaseEraseButton.primaryText = "Erase Button"
        showcaseEraseButton.secondaryText = "Click here to erase all the results so you can start over"
        
        designShowcase(showcase: showcaseEraseButton)
        
        showcaseSortUpButton.setTargetView(view: sortUpButton)
        showcaseSortUpButton.primaryText = "Sort Up Button"
        showcaseSortUpButton.secondaryText = "Click here to sort the results in descending order. You can choose to sort the results by:\n\t\u{2022}Number of times the sight word was practiced.\n\t\u{2022}Percentage of wrong answers.\n\t\u{2022}Percentage of right answers."
        
        designShowcase(showcase: showcaseSortUpButton)
        
        showcaseSortDownButton.setTargetView(view: sortDownButton)
        showcaseSortDownButton.primaryText = "Sort Down Button"
        showcaseSortDownButton.secondaryText = "Click here to sort the results in ascending order. You can choose to sort the results by:\n\t\u{2022}Number of times the sight word was practiced.\n\t\u{2022}Percentage of wrong answers.\n\t\u{2022}Percentage of right answers."
        
        designShowcase(showcase: showcaseSortDownButton)
        
        showcaseAddButton.delegate = self
        showcaseEraseButton.delegate = self
        showcaseSortDownButton.delegate = self
        showcaseSortUpButton.delegate = self
        
        if (words?.count)! > 0 {
            
            showcaseResultsRow.setTargetView(tableView: tableView, section: 0, row: 0)
            showcaseResultsRow.primaryText = "Results of the practice of the sight word."
            showcaseResultsRow.secondaryText = "The results are:\n\t\u{2022}The number on the left shows the number of times the sight word has been practiced.\n\t\u{2022}The green bar shows the percentage of correct answers.\n\t\u{2022}The red bar shows the percentage of wrong answers."
            
            designShowcase(showcase: showcaseResultsRow)
            showcaseResultsRow.delegate = self
            
        sequenceShowcases.temp(showcaseAddButton).temp(showcaseEraseButton).temp(showcaseSortUpButton).temp(showcaseSortDownButton).temp(showcaseResultsRow).start()
            
        } else {
            sequenceShowcases.temp(showcaseAddButton).temp(showcaseEraseButton).temp(showcaseSortUpButton).temp(showcaseSortDownButton).start()
        }
        

    }
    
    func updateUI() {
        
        tableView.rowHeight = 70
        tableView.separatorStyle = .singleLine
        
        userNameLabel.text = selectedUser?.name
        
        addButton.layer.cornerRadius = 5
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.white.cgColor
        let addImage = UIImage(named: "iconPlus")
        let addImageTinted = addImage?.withRenderingMode(.alwaysTemplate)
        addButton.setImage(addImageTinted, for: .normal)
        addButton.tintColor = UIColor.white
        addButton.contentMode = .center
        
        eraseButton.layer.cornerRadius = 5
        eraseButton.layer.borderWidth = 1
        eraseButton.layer.borderColor = UIColor.white.cgColor
        let eraseImage = UIImage(named: "iconErase")
        let eraseImageTinted = eraseImage?.withRenderingMode(.alwaysTemplate)
        eraseButton.setImage(eraseImageTinted, for: .normal)
        eraseButton.tintColor = UIColor.white
        eraseButton.contentMode = .center
        
        helpButton.layer.cornerRadius = 5
        helpButton.layer.borderWidth = 1
        helpButton.layer.borderColor = UIColor.white.cgColor
        let helpImage = UIImage(named: "iconHelp")
        let helpImageTinted = helpImage?.withRenderingMode(.alwaysTemplate)
        helpButton.setImage(helpImageTinted, for: .normal)
        helpButton.tintColor = UIColor.white
        helpButton.contentMode = .center
        
        sortUpButton.layer.cornerRadius = 5
        sortUpButton.layer.borderWidth = 1
        sortUpButton.layer.borderColor = UIColor.white.cgColor
        let sortUpImage = UIImage(named: "iconSortUp")
        let sortUpImageTinted = sortUpImage?.withRenderingMode(.alwaysTemplate)
        sortUpButton.setImage(sortUpImageTinted, for: .normal)
        sortUpButton.tintColor = UIColor.white
        sortUpButton.contentMode = .center
        
        sortDownButton.layer.cornerRadius = 5
        sortDownButton.layer.borderWidth = 1
        sortDownButton.layer.borderColor = UIColor.white.cgColor
        let sortDownImage = UIImage(named: "iconSortDown")
        let sortDownImageTinted = sortDownImage?.withRenderingMode(.alwaysTemplate)
        sortDownButton.setImage(sortDownImageTinted, for: .normal)
        sortDownButton.tintColor = UIColor.white
        sortDownButton.contentMode = .center
        
    }

    //MARK: - Material Showcase Delegate Methods
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        showAddAlert()

    }
    
    @IBAction func eraseButtonTapped(_ sender: UIButton) {
        
        eraseValues()
        wordsNoDuplicates.removeAll()
        loadWords()
        tableView.reloadData()
        
    }
    
    @IBAction func sortUpButtonTapped(_ sender: UIButton) {
        showSortAlert(sortUp : true)
    }
    
    @IBAction func sortDownButtonTapped(_ sender: UIButton) {
        showSortAlert(sortUp : false)
    }
    
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        
        startShowcase()
        
    }
    
    //MARK: - Popup Methods
    
//    func showAddAlert() {
//
//        let alert = UIAlertController(title: "Create List", message: "Write the name of the new list", preferredStyle: .alert)
//
//        var listNameTextField = UITextField()
//        //we set a default name
//        listNameTextField.text = "New List"
//
//        alert.addTextField(configurationHandler: { textField in
//            textField.placeholder = "Write New List Name"
//            listNameTextField = textField
//        })
//
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//
//        let addActionAll = UIAlertAction(title: "Use All", style: .default) { (action) in
//            self.addList(name : listNameTextField.text!, numberOfWords : self.wordsNoDuplicates.count)
//        }
//
//        let addActionTop5 = UIAlertAction(title: "Use Top 5", style: .default) { (action) in
//            self.addList(name : listNameTextField.text!, numberOfWords : 5)
//        }
//
//        let addActionTop10 = UIAlertAction(title: "Use Top 10", style: .default) { (action) in
//            self.addList(name : listNameTextField.text!, numberOfWords : 10)
//        }
//
//        let addActionTop15 = UIAlertAction(title: "Use Top 15", style: .default) { (action) in
//            self.addList(name : listNameTextField.text!, numberOfWords : 15)
//        }
//
//        let addActionTop20 = UIAlertAction(title: "Use Top 20", style: .default) { (action) in
//            self.addList(name : listNameTextField.text!, numberOfWords : 20)
//        }
//
//        if wordsNoDuplicates.count > 5 {
//            alert.addAction(addActionTop5)
//        }
//        if wordsNoDuplicates.count > 10 {
//            alert.addAction(addActionTop10)
//        }
//        if wordsNoDuplicates.count > 15 {
//            alert.addAction(addActionTop15)
//        }
//        if wordsNoDuplicates.count > 20 {
//            alert.addAction(addActionTop20)
//        }
//        alert.addAction(addActionAll)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//
//    }
    
    func showAddAlert() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kButtonHeight: 50,
            kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
            kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
            kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
            
        )
        let alert = SCLAlertView(appearance: appearance)
        
        let listNameTextField = alert.addTextField("Enter list name")
        listNameTextField.autocapitalizationType = .none
        
        alert.addButton("Use All") {
            self.addList(name : listNameTextField.text!, numberOfWords : self.wordsNoDuplicates.count)
        }

        if wordsNoDuplicates.count > 5 {
            alert.addButton("Use Top 5")  {
                self.addList(name : listNameTextField.text!, numberOfWords : 5)
            }
        }
        if wordsNoDuplicates.count > 10 {
            alert.addButton("Use Top 10") {
                self.addList(name : listNameTextField.text!, numberOfWords : 10)
            }
        }
        if wordsNoDuplicates.count > 15 {
            alert.addButton("Use Top 15") {
                self.addList(name : listNameTextField.text!, numberOfWords : 15)
            }
        }
        if wordsNoDuplicates.count > 20 {
            alert.addButton("Use Top 20")  {
                self.addList(name : listNameTextField.text!, numberOfWords : 20)
            }
        }
        
        let colorAlert = UIColor(named: "colorAlertEdit")
        let iconAlert = UIImage(named: "icon-list")
        
        alert.showCustom("Create List", subTitle: "Write the name of the new list", color: colorAlert!, icon: iconAlert!)
        
        listNameTextField.delegate = self
        
    }
    
//    func showSortAlert(sortUp : Bool) {
//
//        let alert = UIAlertController(title: "Sort", message: "What do you want to sort by?", preferredStyle: .actionSheet)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//
//        let sortByTotalAction = UIAlertAction(title: "Total Answered", style: .default) { (action) in
//            if sortUp {
//                self.wordsNoDuplicates.sort(by: { $0.numberTotal > $1.numberTotal })
//                self.tableView.reloadData()
//            } else {
//                self.wordsNoDuplicates.sort(by: { $0.numberTotal < $1.numberTotal })
//                self.tableView.reloadData()
//            }
//        }
//
//        let sortByCorrectAction = UIAlertAction(title: "Correct Answered", style: .default) { (action) in
//            if sortUp {
//                self.wordsNoDuplicates.sort(by: { $0.percentageCorrect > $1.percentageCorrect })
//                for word in self.wordsNoDuplicates{
//                    print("\(word.name) \(word.percentageCorrect)")
//                }
//                self.tableView.reloadData()
//            } else {
//                self.wordsNoDuplicates.sort(by: { $0.percentageCorrect < $1.percentageCorrect })
//                for word in self.wordsNoDuplicates{
//                    print("\(word.name) \(word.percentageCorrect)")
//                }
//                self.tableView.reloadData()
//            }
//        }
//
//        let sortByWrongAction = UIAlertAction(title: "Wrong Answered", style: .default) { (action) in
//            if sortUp {
//                self.wordsNoDuplicates.sort(by: { $0.percentageWrong > $1.percentageWrong })
//                for word in self.wordsNoDuplicates{
//                    print("\(word.name) \(word.percentageWrong)")
//                }
//
//                self.tableView.reloadData()
//            } else {
//                self.wordsNoDuplicates.sort(by: { $0.percentageWrong < $1.percentageWrong })
//                for word in self.wordsNoDuplicates{
//                    print("\(word.name) \(word.percentageWrong)")
//                }
//                self.tableView.reloadData()
//            }
//        }
//
//        alert.addAction(sortByTotalAction)
//        alert.addAction(sortByCorrectAction)
//        alert.addAction(sortByWrongAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//
//    }
    
    func showSortAlert(sortUp : Bool) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kButtonHeight: 50,
            kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
            kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
            kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
            
        )
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Total Answered")  {
            if sortUp {
                self.wordsNoDuplicates.sort(by: { $0.numberTotal > $1.numberTotal })
                self.tableView.reloadData()
            } else {
                self.wordsNoDuplicates.sort(by: { $0.numberTotal < $1.numberTotal })
                self.tableView.reloadData()
            }
        }
        
        alert.addButton("Correct Answered"){
            if sortUp {
                self.wordsNoDuplicates.sort(by: { $0.percentageCorrect > $1.percentageCorrect })
                for word in self.wordsNoDuplicates{
                    print("\(word.name) \(word.percentageCorrect)")
                }
                self.tableView.reloadData()
            } else {
                self.wordsNoDuplicates.sort(by: { $0.percentageCorrect < $1.percentageCorrect })
                for word in self.wordsNoDuplicates{
                    print("\(word.name) \(word.percentageCorrect)")
                }
                self.tableView.reloadData()
            }
        }
        
    alert.addButton("Wrong Answered") {
            if sortUp {
                self.wordsNoDuplicates.sort(by: { $0.percentageWrong > $1.percentageWrong })
                for word in self.wordsNoDuplicates{
                    print("\(word.name) \(word.percentageWrong)")
                }
                
                self.tableView.reloadData()
            } else {
                self.wordsNoDuplicates.sort(by: { $0.percentageWrong < $1.percentageWrong })
                for word in self.wordsNoDuplicates{
                    print("\(word.name) \(word.percentageWrong)")
                }
                self.tableView.reloadData()
            }
        }
        
        let colorAlert = UIColor(named: "colorAlertEdit")
        let iconAlert = UIImage(named: "icon-sort")
        
        alert.showCustom("Sort", subTitle: "What do you want to sort by?", color: colorAlert!, icon: iconAlert!)
        
        
    }
    // MARK: - Tableview Datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsNoDuplicates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath) as! GraphTableViewCell
        
        let word = wordsNoDuplicates[indexPath.row]
        
        cell.wordLabel.text = word.name

        print("\(word.name) ✅ \(word.numberCorrect) ❌ \(word.numberWrong) %correct: \(word.percentageCorrect) %wrong: \(word.percentageWrong)")

        cell.correctCountLabel.text = String(word.percentageCorrect)+"%"
        cell.wrongCountLabel.text = String(word.percentageWrong)+"%"
        cell.totalCountLabel.text = String(word.numberTotal)
        cell.correctBar.frame.size.width = (CGFloat(word.percentageCorrect)/CGFloat(100)) * cell.barsView.frame.size.width
        cell.wrongBar.frame.size.width = (CGFloat(word.percentageWrong)/CGFloat(100)) * cell.barsView.frame.size.width

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
