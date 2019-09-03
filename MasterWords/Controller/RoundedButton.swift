//
//  RoundedButton.swift
//  MasterWords
//
//  Created by Maria Martinez on 8/29/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import UIKit
//import  ChameleonFramework

@IBDesignable
class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
