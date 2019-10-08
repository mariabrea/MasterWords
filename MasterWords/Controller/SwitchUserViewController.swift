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
import Charts


class SwitchUserViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hrsLoggedInLabel: UILabel!
    @IBOutlet weak var minLoggedInLabel: UILabel!
    @IBOutlet weak var secLoggedInLabel: UILabel!
    @IBOutlet weak var hrsPracticeLabel: UILabel!
    @IBOutlet weak var minPracticeLabel: UILabel!
    @IBOutlet weak var secPracticeLabel: UILabel!
    @IBOutlet weak var numCardsPracticedLabel: UILabel!
    @IBOutlet weak var chartView: PieChartView!
    
    let realm = try! Realm()
    
    var lists : Results<SightWordsList>?
    var words : Results<SightWord>?
    
    var selectedUser : User? {
        didSet{
            //loadLists()
        }
    }
    
    let showcaseLogoutButton = MaterialShowcase()
    
    var logoutTime : CFAbsoluteTime = 0.0
    var startTime : Double = 0.0
    var secondsUserSession : Double = 0.0
    var secondsUserPracticedCardsSession : Double = 0.0
    var h1 : Int = 0
    var m1 : Int = 0
    var s1 : Int = 0
    var h2 : Int = 0
    var m2 : Int = 0
    var s2 : Int = 0
    var numberCorrectCardsUserPracticedSession : Int = 0
    var numberWrongCardsUserPracticedSession : Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //select tab of SwitchUser when logOut notofocation posted
        NotificationCenter.default.addObserver(self, selector: #selector(logOut), name: NSNotification.Name(rawValue: "logOut"), object: nil)
        
        updateUI()
        
        checkAutomaticLogOut()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        chartView.isHidden = false
    }

    //set the text of status bar light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation Methods

    func checkAutomaticLogOut() {
//        print("checking automatic logout")
        if defaults.bool(forKey: .automaticLogOut)! {
//            print("automatic logout")
//            print("setting default automaticlogout to false")
            defaults.set(false, forKey: .automaticLogOut)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToUsersVC", sender: self)
            }
            
        } else {
//            print("regular logout")
        }
        
    }
    
    @objc func logOut() {
//        print("logging out")
//        print("setting default automaticlogout to false")
        defaults.set(false, forKey: .automaticLogOut)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToUsersVC", sender: self)
        }
    }
    
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
        
        calculateDataActivityLog()
        
        titleLabel.text = "Activity Log of \(selectedUser?.name ?? "User")"
        hrsLoggedInLabel.text = String(h1)
        minLoggedInLabel.text = String(m1)
        secLoggedInLabel.text = String(s1)
        hrsPracticeLabel.text = String(h2)
        minPracticeLabel.text = String(m2)
        secPracticeLabel.text = String(s2)
        numCardsPracticedLabel.text = String(numberWrongCardsUserPracticedSession + numberCorrectCardsUserPracticedSession)
        
        if !(numberCorrectCardsUserPracticedSession == 0 && numberWrongCardsUserPracticedSession == 0) {
            customizeChart(dataPoints: ["Correct", "Wrong"], values: [Double(numberCorrectCardsUserPracticedSession), Double(numberWrongCardsUserPracticedSession)])
        } else {
            chartView.isHidden = true
        }
        
        
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
//            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = [UIColor(named: "colorButtonBackground"), UIColor(named: "colorAlertEdit")] as! [NSUIColor]
        pieChartDataSet.xValuePosition = .outsideSlice
        pieChartDataSet.sliceSpace = 4
        pieChartDataSet.entryLabelColor = UIColor(named: "colorBarBackground")
        pieChartDataSet.entryLabelFont = UIFont(name: "Montserrat", size: 13)
        pieChartDataSet.valueFont = UIFont(name: "Montserrat", size: 13)!
        
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        chartView.data = pieChartData
        chartView.extraRightOffset = 20
        chartView.extraLeftOffset = 20
    }
    

    //MARK: Data Functions
    func calculateDataActivityLog() {
//        print("Calculating Activity Log Data")
        logoutTime = Double(CFAbsoluteTimeGetCurrent())
        startTime = defaults.double(forKey: .timeUserStartSession)!
        secondsUserSession = logoutTime - startTime
        (h1, m1, s1) = secondsToHoursMinutesSeconds(seconds: Int(secondsUserSession.rounded(.down)))
        
        secondsUserPracticedCardsSession = defaults.double(forKey: .secondsUserPracticedCardsSession)!
        (h2, m2, s2) = secondsToHoursMinutesSeconds(seconds: Int(secondsUserPracticedCardsSession.rounded(.down)))
        
        numberCorrectCardsUserPracticedSession = defaults.integer(forKey: .numberCorrectCardsUserPracticedSession)
        numberWrongCardsUserPracticedSession = defaults.integer(forKey: .numberWrongCardsUserPracticedSession)
    }
    
    // MARK: - IBAction Methods
    
     @IBAction func logoutButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToUsersVC", sender: self)
     }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        startShowcase()
    }
}
