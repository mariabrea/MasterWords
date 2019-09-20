//
//  AlertFunctions.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/18/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import SCLAlertView

public func createWarningAlert(title: String, subtitle: String) {
    let appearance = SCLAlertView.SCLAppearance(
        kButtonHeight: 50,
        kTitleFont: UIFont(name: "Montserrat-SemiBold", size: 17)!,
        kTextFont: UIFont(name: "Montserrat-Regular", size: 16)!,
        kButtonFont: UIFont(name: "Montserrat-SemiBold", size: 17)!
        
    )
    let alert = SCLAlertView(appearance: appearance)
    let colorAlert = UIColor(named: "colorAlertEdit")
    let iconAlert = UIImage(named: "icon-warning")
    
    alert.showCustom(title, subTitle: subtitle, color: colorAlert!, icon: iconAlert!, closeButtonTitle: "Close", animationStyle: .topToBottom)
}


