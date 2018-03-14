//
//  SightWord.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/13/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import RealmSwift

class SightWord : Object {
    @objc dynamic var name : String = ""
    var parentList = LinkingObjects(fromType: SightWordsList.self, property: "sightWords")
}

