//
//  UserDefaultsManager.swift
//  InstaSaver
//
//  Created by Vyacheslav Bakinskiy on 1/18/21.
//

import Foundation

enum UserDefaultsKeys: String, RawRepresentable {
    case launchCount
    case lastVersionPromptedForReviewKey
    case firstLaunch
}

final class UserDefaultsManager {
    
    //MARK: - Application Launch counting
    
    static var isTheFirstAppLaunch: Bool {
        if let _ = UserDefaults.standard.string(forKey: UserDefaultsKeys.firstLaunch.rawValue) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.firstLaunch.rawValue)
            return true
        }
    }
    
    static func appLaunchCounting() {
        let count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.launchCount.rawValue)

        if count < 3 {
            UserDefaults.standard.set(count + 1, forKey: UserDefaultsKeys.launchCount.rawValue)
            UserDefaults.standard.synchronize()
        }
        
//        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.launchCount.rawValue)
    }
}
