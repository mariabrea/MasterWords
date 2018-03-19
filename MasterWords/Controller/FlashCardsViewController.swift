//
//  FlasCardsViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/15/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import Koloda

class FlashCardsViewController: UIViewController{

    @IBOutlet weak var cardView: KolodaView!
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var sadLabel: UILabel!
    @IBOutlet weak var happyButton: UIButton!
    @IBOutlet weak var happyLabel: UILabel!

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var repeatAllButton: UIButton!
    @IBOutlet weak var repeatWrongButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var numberCorrect : Int = 0
    var numberWrong : Int = 0
    
    let realm = try! Realm()
    
    var listWordsToPractice = [SightWord]()
    var listWordsWrong = [SightWord]()
    var listOriginalWords = [SightWord]()
    
    var wordsList : Results<SightWord>?
    
    var selectedList : SightWordsList? {
        didSet{
            loadSightWords()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        cardView.delegate = self
        cardView.dataSource = self
        
    }
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        sadButton.setImage(UIImage(named: "sadFace") , for: .normal)
        sadButton.tintColor = FlatRed()
        happyButton.setImage(UIImage(named: "happyFace") , for: .normal)
        happyButton.tintColor = FlatLimeDark()
        
        popupView.alpha = 0
        popupView.layer.borderColor = FlatPlum().cgColor
        popupView.layer.borderWidth = 1
        
        popupTitle.layer.borderWidth = 1
        popupTitle.layer.borderColor = FlatPlum().cgColor
        
        repeatAllButton.layer.borderWidth = 1
        repeatAllButton.layer.borderColor = FlatPlum().cgColor
        repeatAllButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        repeatWrongButton.layer.borderWidth = 1
        repeatWrongButton.layer.borderColor = FlatPlum().cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = FlatPlum().cgColor
        
        
        print(wordsList as Any)
        if let numberWordsToPractice = wordsList?.count {
            for i in 0...numberWordsToPractice - 1 {
                listWordsToPractice.append(wordsList![i])
            }
        }
        print(listWordsToPractice)
        
        

    }
    
    //MARK: - Navigation Methods
    
    @IBAction func happyButtonTapped(_ sender: UIButton) {
        cardView.reloadData()
        //happyButton.isEnabled = false
    }
    
    
    
    @IBAction func repeatAllButtonTapped(_ sender: UIButton) {
        repeatWrongButton.isHidden = false
        
        resetCounters()
        
        listWordsToPractice.removeAll()
        listWordsWrong.removeAll()
        
        if let numberWordsToPractice = wordsList?.count {
            for i in 0...numberWordsToPractice - 1 {
                listWordsToPractice.append(wordsList![i])
            }
        }

        
        cardView.resetCurrentCardIndex()
    }
    
    @IBAction func repeatWrongButtonTapped(_ sender: UIButton) {
        
        listWordsToPractice.removeAll()
        let numberWordsToPractice = listWordsWrong.count
        
        for i in 0...numberWordsToPractice - 1 {
            listWordsToPractice.append(listWordsWrong[i])
        }
        
        listWordsWrong.removeAll()
        
        resetCounters()
        cardView.resetCurrentCardIndex()
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        popupView.alpha = 0
        repeatWrongButton.isHidden = false
    }
    
    func resetCounters() {
        numberWrong = 0
        numberCorrect = 0
        sadLabel.text = "0"
        happyLabel.text = "0"
    }
    
    func hangPopup() {
        
        if listWordsWrong.count == 0 {
            repeatWrongButton.isHidden = true
        }
        
        resultsLabel.text = "CORRECT: \(numberCorrect)\nWRONG: \(numberWrong)\n\nDo you want to keep practicing?"
        
        popupView.transform = CGAffineTransform(scaleX: 0.3, y: 1)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            self.popupView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        
        popupView.alpha = 1
        
    }
    
    //MARK: - Database Methods
    
    func loadSightWords() {
        wordsList = selectedList?.sightWords.sorted(byKeyPath: "name", ascending: true)
    }
    
    func updateModel(index: Int, correct : Bool) {
        if let word = self.wordsList?.filter("index == \(index)").first {
            do{
                try self.realm.write {
                    if correct {
                        word.numberCorrect = word.numberCorrect + 1
                    } else {
                        word.numberWrong = word.numberWrong + 1
                    }
                    
                }
            } catch {
                print("Error updating word numbers \(error)")
            }
        }
    }

}

extension FlashCardsViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("No more cards")
        
        cardView = koloda
        
        hangPopup()
        
        //koloda.reloadData()
        
//        if listWordsToPractice.count > 0 {
//            happyButton.isEnabled = true
//        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .left {
            print("Left")
            numberWrong += 1
            sadLabel.text = String(numberWrong)
            updateModel(index: listWordsToPractice[index].index, correct : true)
            listWordsWrong.append(listWordsToPractice[index])
            
        } else {
            print("Right")
            numberCorrect += 1
            happyLabel.text = String(numberCorrect)
            updateModel(index: listWordsToPractice[index].index, correct : false)
        }
    }
}

extension FlashCardsViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        //return wordsList?.count ?? 1
        return listWordsToPractice.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 20, y: self.view.safeAreaInsets.top + 20, width: self.view.frame.width - 40 , height: self.view.safeAreaLayoutGuide.layoutFrame.height*0.85 - 40))
        view.backgroundColor = UIColor.randomFlat
        
        let sightWordLabel = UILabel(frame: CGRect(x: (view.frame.width - 200)/2 , y: (view.frame.height - 100)/2, width: 200, height: 100))
        sightWordLabel.textAlignment = .center
        sightWordLabel.textColor = ContrastColorOf(view.backgroundColor!, returnFlat: true)
        sightWordLabel.text = listWordsToPractice[index].name
        sightWordLabel.font = UIFont (name: "GelPenHeavy", size: 80)
        view.addSubview(sightWordLabel)
        
        return view
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
        let view = UIView(frame: CGRect(x: 20, y: self.view.safeAreaInsets.top + 20, width: self.view.frame.width - 40 , height: self.view.safeAreaLayoutGuide.layoutFrame.height*0.85 - 40)) as? OverlayView
        view?.backgroundColor = UIColor.randomFlat
        return view
    }
    
}
