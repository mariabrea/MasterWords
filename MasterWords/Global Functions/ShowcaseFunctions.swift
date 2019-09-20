//
//  ShowcaseFunctions.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/4/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import MaterialShowcase

public func designShowcase(showcase: MaterialShowcase) {
    
    // Background
    showcase.backgroundPromptColor = UIColor(named: "colorShowcaseBackground")
    showcase.backgroundPromptColorAlpha = 0.9
    showcase.backgroundViewType = .full // default is .circle
    // Target
    //        showcase.targetTintColor = UIColor.green
    showcase.targetHolderRadius = 25
    showcase.targetHolderColor = UIColor(named: "colorShowcaseHolder")
    // Text
    showcase.primaryTextColor = UIColor(named: "colorShowcaseHolder")
    showcase.secondaryTextColor = UIColor(named: "colorShowcaseHolder")
    showcase.primaryTextSize = 20
    showcase.secondaryTextSize = 15
    showcase.primaryTextFont = UIFont.boldSystemFont(ofSize: showcase.primaryTextSize)
    showcase.secondaryTextFont = UIFont.systemFont(ofSize: showcase.secondaryTextSize)
    //Alignment
    showcase.primaryTextAlignment = .justified
    showcase.secondaryTextAlignment = .justified
    
    // Animation
    showcase.aniComeInDuration = 0.5 // unit: second
    showcase.aniGoOutDuration = 0.5 // unit: second
    showcase.aniRippleScale = 1.5
    showcase.aniRippleColor = UIColor(named: "colorShowcaseHolder")
    showcase.aniRippleAlpha = 0.2
    
}

public func designShowcase(showcase: MaterialShowcase, sizeHolder: String) {
    
    // Background
    showcase.backgroundPromptColor = UIColor(named: "colorShowcaseBackground")
    showcase.backgroundPromptColorAlpha = 0.7
    showcase.backgroundViewType = .full // default is .circle
    // Target
    //        showcase.targetTintColor = UIColor.green
    if sizeHolder == "small" {
        showcase.targetHolderRadius = 25
    } else {
        showcase.targetHolderRadius = 45
    }
    
    showcase.targetHolderColor = UIColor(named: "colorShowcaseHolder")
    // Text
    showcase.primaryTextColor = UIColor(named: "colorShowcaseHolder")
    showcase.secondaryTextColor = UIColor(named: "colorShowcaseHolder")
    showcase.primaryTextSize = 20
    showcase.secondaryTextSize = 15
    showcase.primaryTextFont = UIFont.init(name: "Montserrat-SemiBold", size: 20)
//    showcase.primaryTextFont = UIFont.boldSystemFont(ofSize: showcase.primaryTextSize)
    showcase.secondaryTextFont = UIFont.init(name: "Montserrat-Regular", size: 15)
//    showcase.secondaryTextFont = UIFont.systemFont(ofSize: showcase.secondaryTextSize)
    //Alignment
    showcase.primaryTextAlignment = .justified
    showcase.secondaryTextAlignment = .justified
    
    // Animation
    showcase.aniComeInDuration = 0.5 // unit: second
    showcase.aniGoOutDuration = 0.5 // unit: second
    showcase.aniRippleScale = 1.5
    showcase.aniRippleColor = UIColor(named: "colorShowcaseHolder")
    showcase.aniRippleAlpha = 0.2
    
}
