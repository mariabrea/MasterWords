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
    @IBOutlet weak var leftCardsButton: RoundButton!
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var repeatAllButton: UIButton!
    @IBOutlet weak var repeatWrongButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var stopButton : UIBarButtonItem!
    
    //variable needed to play sound
    var audioPlayer : AVAudioPlayer!
    let correctAnswerSoundFileName : String = "38798943_correct-answer-bell-gliss-01"
    let wrongAnswerSoundFileName : String = "131657__bertrof__game-sound-wrong"
    let soundFileExtension : String = "wav"

    
    var numberCorrect : Int = 0
    var numberWrong : Int = 0
    var leftCardsToPractice : Int = 0
    
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
    let showcaseSadFace = MaterialShowcase()
    let showcaseHappyFace = MaterialShowcase()
    let showcaseLeftCards = MaterialShowcase()
    let showcaseStopButton = MaterialShowcase()
    
    let defaults = UserDefaults()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        cardView.delegate = self
        cardView.dataSource = self
        
    }
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        updateUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        print("viewWillAppear FlashCards")
    }
    
    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    //MARK: - Navigation Methods
    
    func updateUI() {
        
//        self.tabBarController?.tabBar.isHidden = true
        
        let helpButton = UIBarButtonItem(image: UIImage(named: "iconHelp"), style: .plain, target: self, action: #selector(startShowcase))
        helpButton.tintColor = .white
        stopButton = UIBarButtonItem(image: UIImage(named: "iconCancel"), style: .plain, target: self, action: #selector(stopButtonTapped))
        stopButton.tintColor = .white
        self.navigationItem.rightBarButtonItems = [helpButton, stopButton]
        
        sadButton.setImage(UIImage(named: "sadFace") , for: .normal)
        sadButton.tintColor = UIColor.flatRed
        happyButton.setImage(UIImage(named: "happyFace") , for: .normal)
        happyButton.tintColor = UIColor.flatLime
        
        popupView.alpha = 0
        popupView.layer.borderColor = UIColor(named: "colorButtonBackground")?.cgColor
        popupView.layer.borderWidth = 1
        popupView.layer.cornerRadius = 5
        
        popupTitle.layer.borderWidth = 1
        popupTitle.layer.borderColor = UIColor(named: "colorButtonBackground")?.cgColor
        
        if let numberWordsToPractice = wordsList?.count {
            leftCardsToPractice = numberWordsToPractice
            
            for i in 0...numberWordsToPractice - 1 {
                listWordsToPractice.append(wordsList![i])
                listWordsToPractice = listWordsToPractice.shuffled()
            }
        }
        
        leftCardsButton.setTitle(String(leftCardsToPractice), for: .normal)
        
    }
    
    @objc func startShowcase() {
        
        showcaseStopButton.setTargetView(barButtonItem: stopButton)
        showcaseStopButton.primaryText = "Stop Button"
        showcaseStopButton.secondaryText = "Click here to stop de practice."
        
        designShowcase(showcase: showcaseStopButton)
        showcaseStopButton.delegate = self
        
        showcaseSadFace.setTargetView(view: sadButton)
        showcaseSadFace.primaryText = "Sad face"
        showcaseSadFace.secondaryText = "Number of wrong answers. Swipe the card to the left if the answer is wrong."
        
        designShowcase(showcase: showcaseSadFace)
        showcaseSadFace.delegate = self
        
        showcaseHappyFace.setTargetView(view: happyButton)
        showcaseHappyFace.primaryText = "Happy face"
        showcaseHappyFace.secondaryText = "Number of right answers. Swipe the card to the right if the answer is correct."
        
        designShowcase(showcase: showcaseHappyFace)
        showcaseHappyFace.delegate = self
        
        showcaseLeftCards.setTargetView(view: leftCardsButton)
        showcaseLeftCards.primaryText = "Left Cards"
        showcaseLeftCards.secondaryText = "Number of remaining cards to practice"
        
        designShowcase(showcase: showcaseLeftCards)
        showcaseLeftCards.delegate = self
 sequenceShowcases.temp(showcaseStopButton).temp(showcaseSadFace).temp(showcaseLeftCards).temp(showcaseHappyFace).start()
        
    }
    
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequenceShowcases.showCaseWillDismis()
    }
    
    @objc func stopButtonTapped() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadGraph"), object: nil)
        
        stopPracticeTime()
        
//        self.tabBarController?.tabBar.isHidden = false
        
        performSegue(withIdentifier: "unwindToLists", sender: self)
    }
    
    func stopPracticeTime() {
        let timePracticeEnd = Double(CFAbsoluteTimeGetCurrent())
        let timePracticeStart = defaults.double(forKey: .timeUserStartCardsPractice)
        let secondsUserPracticedCards = defaults.double(forKey: .secondsUserPracticedCardsSession)
        defaults.set(secondsUserPracticedCards! + (timePracticeEnd - timePracticeStart!), forKey: .secondsUserPracticedCardsSession)
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func repeatAllButtonTapped(_ sender: UIButton) {
        repeatWrongButton.isHidden = false
        
        resetCounters()
        
        listWordsToPractice.removeAll()
        listWordsWrong.removeAll()
        
        if let numberWordsToPractice = wordsList?.count {
            leftCardsToPractice = numberWordsToPractice
            leftCardsButton.setTitle(String(leftCardsToPractice), for: .normal)
            for i in 0...numberWordsToPractice - 1 {
                listWordsToPractice.append(wordsList![i])
                listWordsToPractice = listWordsToPractice.shuffled()
            }
        }

        cardView.resetCurrentCardIndex()
        
        popupView.alpha = 0

    }
    
    @IBAction func repeatWrongButtonTapped(_ sender: UIButton) {
        
        listWordsToPractice.removeAll()
        let numberWordsToPractice = listWordsWrong.count
        leftCardsToPractice = numberWordsToPractice
        leftCardsButton.setTitle(String(leftCardsToPractice), for: .normal)
        
        for i in 0...numberWordsToPractice - 1 {
            listWordsToPractice.append(listWordsWrong[i])
            listWordsToPractice = listWordsToPractice.shuffled()
        }
        
        listWordsWrong.removeAll()
        
        resetCounters()
        cardView.resetCurrentCardIndex()
        
        popupView.alpha = 0

        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        popupView.alpha = 0

        repeatWrongButton.isHidden = false
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadGraph"), object: nil)
        
        stopPracticeTime()
        
//        self.tabBarController?.tabBar.isHidden = false
        
        performSegue(withIdentifier: "unwindToLists", sender: self)
        
        AppStoreReviewManager.requestReviewIfAppropriate()
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

        cardView = koloda
        
        hangPopup()

    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {

    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        leftCardsToPractice -= 1
        leftCardsButton.setTitle(String(leftCardsToPractice), for: .normal)
        if direction == .left {

            if defaults.bool(forKey: .audio)!{
                playSound(soundFileName: wrongAnswerSoundFileName, soundFileExtension: soundFileExtension)
            }
            
            numberWrong += 1
            sadLabel.text = String(numberWrong)
            
            let numberWrongCardsUserPracticedSession = defaults.integer(forKey: .numberWrongCardsUserPracticedSession)
            defaults.set(numberWrongCardsUserPracticedSession + 1, forKey: .numberWrongCardsUserPracticedSession)
            
            updateModel2(wordName: listWordsToPractice[index].name, correct : false)
            listWordsWrong.append(listWordsToPractice[index])
            
        } else {

            if defaults.bool(forKey: .audio)! {
                playSound(soundFileName: correctAnswerSoundFileName, soundFileExtension: soundFileExtension)
            }
            
            numberCorrect += 1
            happyLabel.text = String(numberCorrect)
            
            let numberCorrectCardsUserPracticedSession = defaults.integer(forKey: .numberCorrectCardsUserPracticedSession)
            defaults.set(numberCorrectCardsUserPracticedSession + 1, forKey: .numberCorrectCardsUserPracticedSession)
            
            updateModel2(wordName: listWordsToPractice[index].name, correct : true)
        }
    }
}

extension FlashCardsViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return listWordsToPractice.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 20, y: self.view.safeAreaInsets.top + 20, width: self.view.frame.width - 40 , height: self.view.safeAreaLayoutGuide.layoutFrame.height*0.85 - 40))
        view.backgroundColor = UIColor.randomFlat
        view.layer.cornerRadius = 15
        
        let sightWordLabel = UILabel(frame: CGRect(x: 0 , y: (view.frame.height - 150)/2, width: view.frame.width, height: 150))
        sightWordLabel.textAlignment = .center
        sightWordLabel.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: view.backgroundColor!, isFlat: true)
        sightWordLabel.text = listWordsToPractice[index].name
        if UIDevice.current.userInterfaceIdiom == .pad {
            sightWordLabel.font = UIFont (name: "GelPenHeavy", size: 120)
        } else {
            sightWordLabel.font = UIFont (name: "GelPenHeavy", size: 80)
        }
        
        //adjust font size to fit in the card view, in case of too long words
        sightWordLabel.adjustsFontSizeToFitWidth = true
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
