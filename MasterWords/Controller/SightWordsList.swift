//
//  SightWordsList.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import RealmSwift

class SightWordsList : Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let sightWords = List<SightWord>()
    
}
