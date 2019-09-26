//
//  UserDefaultsFunctions.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/17/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Key: String {
        case audio
        case timesAppLaunched
        case reviewWorthyActionCount
        case lastReviewRequestAppVersion
        case reviewWorthyActionCountReseted
        case timeUserStartSession
        case timeUserStartCardsPractice
        case secondsUserPracticedCardsSession
        case numberCorrectCardsUserPracticedSession
        case numberWrongCardsUserPracticedSession
        case automaticLogOut
    }
    
    func exists(key: Key) -> Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
    
    func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func bool(forKey key: Key) -> Bool? {
        return bool(forKey: key.rawValue)
    }
    
    func double(forKey key: Key) -> Double? {
        return double(forKey: key.rawValue)
    }
    
    func set(_ integer: Int, forKey key: Key) {
        set(integer, forKey: key.rawValue)
    }
    
    func set(_ bool: Bool, forKey key: Key) {
        set(bool, forKey: key.rawValue)
    }
    
    func set(_ double: Double, forKey key: Key) {
        set(double, forKey: key.rawValue)
    }
    
    func set(_ object: Any?, forKey key: Key) {
        set(object, forKey: key.rawValue)
    }
    
}
