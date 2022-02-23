//
//  RateManager.swift
//  InstaSaver
//
//  Created by Vyacheslav Bakinskiy on 1/18/21.
//

import UIKit
import StoreKit

final class RateManager {
    static func requestReviewManually() {
        SKStoreReviewController.requestReview()
    }
    
    static func requestReviewAutomatically() {
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey.rawValue)
        
        let count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.launchCount.rawValue)
        
        if count == 2 || (count > 2 && currentVersion != lastVersionPromptedForReview) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey.rawValue)
            })
        }
    }
}
