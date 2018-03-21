//
//  User.swift
//  MasterWords
//
//  Created by Maria Martinez on 3/21/18.
//  Copyright © 2018 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import RealmSwift

class User : Object {
    @objc dynamic var name : String = ""
    var userLists = List<SightWordsList>()
}

