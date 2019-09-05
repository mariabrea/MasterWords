//
//  FlasCardsViewController.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/15/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import UIKit
import RealmSwift
//import ChameleonFramework
import Koloda
import AVFoundation
import MaterialShowcase

class FlashCardsViewController: UIViewController, MaterialShowcaseDelegate {

    
    
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
    
    //variable needed to play sound
    var audioPlayer : AVAudioPlayer!
    let correctAnswerSoundFileName : String = "38798943_correct-answer-bell-gliss-01"
    let wrongAnswerSoundFileName : String = "43162713_comical-rubber-squeak-01"
    let soundFileExtension : String = "wav"

    
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
    
    let sequenceShowcases = MaterialShowcaseSequence()
    let showcaseSightWordCard = MaterialShowcase()
    let showcaseSadFace = MaterialShowcase()
    let showcaseHappyFace = MaterialShowcase()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        cardView.delegate = self
        cardView.dataSource = self
                
    }
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        let helpButton = UIBarButtonItem(image: UIImage(named: "iconHelp"), style: .plain, target: self, action: #selector(startShowcase))
        helpButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = helpButton
        
        
        sadButton.setImage(UIImage(named: "sadFace") , for: .normal)
        sadButton.tintColor = UIColor.flatRed
        happyButton.setImage(UIImage(named: "happyFace") , for: .normal)
        happyButton.tintColor = UIColor.flatLime
        
        popupView.alpha = 0
        popupView.layer.borderColor = UIColor.flatPlum.cgColor
        popupView.layer.borderWidth = 1
        
        popupTitle.layer.borderWidth = 1
        popupTitle.layer.borderColor = UIColor.flatPlum.cgColor
        
        repeatAllButton.layer.borderWidth = 1
        repeatAllButton.layer.borderColor = UIColor.flatPlum.cgColor
        repeatAllButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        repeatWrongButton.layer.borderWidth = 1
        repeatWrongButton.layer.borderColor = UIColor.flatPlum.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.flatPlum.cgColor
        
        
        if let numberWordsToPractice = wordsList?.count {
            for i in 0...numberWordsToPractice - 1 {
                listWordsToPractice.append(wordsList![i])
            }
        }

    }
    
    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    //MARK: Navigation Methods
    
    @objc func startShowcase() {
        
        showcaseSightWordCard.setTargetView(view: cardView)
        showcaseSightWordCard.primaryText = "Sight word card"
        showcaseSightWordCard.secondaryText = "Swipe to the left if the answer is wrong.\nSwipe it to the right if the answer is right."
        
        designShowcase(showcase: showcaseSightWordCard)
        showcaseSightWordCard.delegate = self
        
        showcaseSadFace.setTargetView(view: sadButton)
        showcaseSadFace.primaryText = "Sad face"
        showcaseSadFace.secondaryText = "Number of wrong answers."
        
        designShowcase(showcase: showcaseSadFace)
        showcaseSadFace.delegate = self
        
        showcaseHappyFace.setTargetView(view: happyButton)
        showcaseHappyFace.primaryText = "Happy face"
        showcaseHappyFace.secondaryText = "Number of right answers"
        
        designShowcase(showcase: showcaseHappyFace)
        showcaseHappyFace.delegate = self
        
            sequenceShowcases.temp(showcaseSightWordCard).temp(showcaseSadFace).temp(showcaseHappyFace).start()
        
    }
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    //MARK: - IBAction Methods
    
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadGraph"), object: nil)
        
        performSegue(withIdentifier: "unwindToLists", sender: self)
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
    
    func playSound(soundFileName: String, soundFileExtension : String) {
        
        let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: soundFileExtension)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch {
            
            print(error)
            
        }
        
        audioPlayer.play()
        
    }
    
    //MARK: - Database Methods
    
    func loadSightWords() {
        wordsList = selectedList?.sightWords.sorted(byKeyPath: "name", ascending: true)
        print("loadSightWords")
//        print(wordsList)
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
    
    func updateModel2(wordName: String, correct : Bool) {
        print("name == \(wordName)")
        print(self.wordsList as Any)
        if let word = self.wordsList?.filter("name == %@", wordName).first {
            
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

//MARK: Koloda Methods

extension FlashCardsViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("No more cards")
        
        cardView = koloda
        
        hangPopup()

    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {

    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .left {
            print("Left")
            playSound(soundFileName: wrongAnswerSoundFileName, soundFileExtension: soundFileExtension)
            numberWrong += 1
            sadLabel.text = String(numberWrong)
            updateModel2(wordName: listWordsToPractice[index].name, correct : false)
            listWordsWrong.append(listWordsToPractice[index])
            
        } else {
            print("Right")
            playSound(soundFileName: correctAnswerSoundFileName, soundFileExtension: soundFileExtension)
            numberCorrect += 1
            happyLabel.text = String(numberCorrect)
            updateModel2(wordName: listWordsToPractice[index].name, correct : true)
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
        view.layer.cornerRadius = 15
        
        let sightWordLabel = UILabel(frame: CGRect(x: 0 , y: (view.frame.height - 100)/2, width: view.frame.width, height: 100))
        sightWordLabel.textAlignment = .center
        sightWordLabel.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: view.backgroundColor!, isFlat: true)
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
