//
//  AppStoreReviewManager.swift
//  MasterWords
//
//  Created by Maria Martinez on 9/16/19.
//  Copyright © 2019 Maria Martinez Guzman. All rights reserved.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
    // Declare a constant value to specify the number of times that user must perform a review-worthy action.
    static let minimumReviewWorthyActionCount = 30
    
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main
        // Read the current bundle version and the last bundle version used during the last prompt (if any).
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

        if !defaults.exists(key: .reviewWorthyActionCountReseted) {
            defaults.set(false, forKey: .reviewWorthyActionCountReseted)
        }
        
        //if the version of the app is changed we reset 'reviewWorthyActionCount'
        if lastVersion != currentVersion && !defaults.bool(forKey: .reviewWorthyActionCountReseted)! {
            defaults.set(0, forKey: .reviewWorthyActionCount)
            defaults.set(true, forKey: .reviewWorthyActionCountReseted)
        }
        
        // Read the current number of actions that the user has performed since the last requested review from the User Defaults.
        var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
        
        print("actionCount: \(actionCount)")
        
        // Increment the action count value read from User Defaults
        actionCount += 1
        
        // Set the incremented count back into the user defaults for the next time that you trigger the function
        defaults.set(actionCount, forKey: .reviewWorthyActionCount)
        
        // Check if the action count has now exceeded the minimum threshold to trigger a review. If it hasn’t, the function will now return.
        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }

        // Check if this is the first request for this version of the app before continuing.
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        // Ask StoreKit to request a review.
        SKStoreReviewController.requestReview()
        
        // Reset the action count and store the current version in User Defaults so that we don’t request again on this version of the app.
        defaults.set(0, forKey: .reviewWorthyActionCount)
        defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
        defaults.set(false, forKey: .reviewWorthyActionCountReseted)
    }
    
    
}
