//
//  FollowerController.swift
//  InstaFeed WatchKit Extension
//
//  Created by Hemal on 08/01/2021.
//

import WatchKit
import Foundation

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto
import WatchConnectivity
import SwiftWatchConnectivity

class FollowerController: WKInterfaceController {
    
    @IBOutlet private var loadingLabel: WKInterfaceLabel!
    private var loadingTimer = Timer()
    private var progressTracker = 1
    @IBOutlet weak var currencyTable: WKInterfaceTable!
    var followers: [User]?
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        
        let dict = context as! Dictionary<String, Any>
        followers = dict["follower"] as? [User]
    }
    
    override func willActivate() {
        getDataFromApi()
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
extension FollowerController {
    func getDataFromApi() {
        var rowTypes = [""]
        
        for _ in 0..<followers!.count {
            rowTypes.append("FollowRowController")
        }
        
        self.currencyTable.setRowTypes(rowTypes)

        for index in 0..<followers!.count {
            guard let controller = self.currencyTable.rowController(at: index+1) as? FollowRowController else { continue }
            controller.model = followers?[index]
        }
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let current = followers?[rowIndex-1] {
            let dict = ["user": current]
            pushController(withName: "MyProfileInterfaceController", context: dict)
        }
    }
}
