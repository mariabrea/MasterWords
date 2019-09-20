//
//  GlobalFunctions.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/19/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import Foundation

public func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600 % 60))
}

