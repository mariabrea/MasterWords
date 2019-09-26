//
//  CustomWindow.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/20/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import UIKit

class CustomWindow: UIWindow {

    var timer = Timer()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        resetTimer()
        return false
    }
    
    @objc func resetTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(logOutNotification), userInfo: nil, repeats: false)
    }
    
    @objc func logOutNotification() {
//        print("notifying logOut")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logOut"), object: nil)
    }

}
