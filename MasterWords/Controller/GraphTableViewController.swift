//
//  GraphTableViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/19/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class GraphTableViewCell: UITableViewCell {
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var correctCountLabel: UILabel!
    @IBOutlet weak var wrongCountLabel: UILabel!
    @IBOutlet weak var correctBar: UIView!
    @IBOutlet weak var wrongBar: UIView!
    @IBOutlet weak var barsView: UIView!

    
}

class GraphTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var words : Results<SightWord>?
    
    var wordsNoDuplicates = [Word]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.dataSource = self
//        tableView.delegate = self
        
        loadWords()
        
        tableView.rowHeight = 70
        tableView.separatorStyle = .singleLine
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
    }
    
    //MARK: - Database Methods
    
    func loadWords(){
        
        words = realm.objects(SightWord.self).sorted(byKeyPath: "name", ascending: true)

        print(words as Any)
        
        if let numberRows = words?.count {
            if numberRows > 0 {
                
                let newWord = Word()
                newWord.name = words![0].name
                newWord.numberCorrect = words![0].numberCorrect
                newWord.numberWrong = words![0].numberWrong
                wordsNoDuplicates.append(newWord)
                for i in 1...numberRows-1 {
                    if words![i].name == words![i-1].name {
                        wordsNoDuplicates.last?.numberCorrect += words![i].numberCorrect
                        wordsNoDuplicates.last?.numberWrong += words![i].numberWrong
                        
                    } else {
                        let newWord = Word()
                        newWord.name = words![i].name
                        newWord.numberCorrect = words![i].numberCorrect
                        newWord.numberWrong = words![i].numberWrong
                        wordsNoDuplicates.append(newWord)
                    }
                }
            }
        }
        
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsNoDuplicates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath) as! GraphTableViewCell
        
        //if let word = words?[indexPath.row]{
        let word = wordsNoDuplicates[indexPath.row]
            
            print("\(word.name) ✅ \(word.numberCorrect) ❌ \(word.numberWrong)")
            
            cell.wordLabel.text = word.name
            let totalCount = word.numberWrong + word.numberCorrect
            var percentageCorrect : Int = 0
            var percentageWrong : Int = 0
            if totalCount > 0{
                percentageCorrect = Int(round((Double(word.numberCorrect)/Double(totalCount))*100))
                percentageWrong = 100 - percentageCorrect
            }
            
            
            cell.correctCountLabel.text = String(percentageCorrect)+"%"
            cell.wrongCountLabel.text = String(percentageWrong)+"%"
            cell.totalCountLabel.text = String(totalCount)
            
            print(CGFloat(percentageCorrect)/CGFloat(100))
            print("cell.barsView.frame.size.width \(cell.barsView.frame.size.width)")
            cell.correctBar.frame.size.width = (CGFloat(percentageCorrect)/CGFloat(100)) * cell.barsView.frame.size.width
            print("cell.correctBar.frame.size.width \(cell.correctBar.frame.size.width)")
            cell.wrongBar.frame.size.width = (CGFloat(percentageWrong)/CGFloat(100)) * cell.barsView.frame.size.width
            print("cell.wrongBar.frame.size.width \(cell.wrongBar.frame.size.width)")
            
        
        
        return cell
    }
    
 

}
