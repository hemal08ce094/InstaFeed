//
//  InterfaceController.swift
//  InstaFeed WatchKit Extension
//
//  Created by Hemal on 29/12/2020.
//

import WatchKit
import Foundation
import Combine

import ComposableRequest
import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto
import WatchConnectivity
import SwiftWatchConnectivity

class InterfaceController: WKInterfaceController {
   
    @IBOutlet weak var feedTableview: WKInterfaceTable!
    private var subscriptions: Set<AnyCancellable> = []
    var startInt = 0
    var shouldReloadTable = true
    
    var current: User?
    var followers: [User]?

    var myFeedDataArray: NSMutableArray?
    var appendFollowers: [User] {
        get { [] }
        set { followers?.append(contentsOf: newValue) }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        SwiftWatchConnectivity.shared.delegate = self
        feedTableview.curvesAtTop = true
        feedTableview.curvesAtBottom = true
        shouldReloadTable = true
        myFeedClicked()
    }
    
    override func didAppear() {
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    func getToken() {
    
        let userDefaults = UserDefaults(suiteName: "com.hemalM.InstaFeed.watchkitapp")!
        
        // Read/Get Data
        if let data = userDefaults.data(forKey: "userId") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let tokenData = try decoder.decode(Secret.self, from: data)
                print(tokenData)
            } catch {
                print("Unable to Decode Note (\(error))")
                askForLoginToken()
            }
        } else {
            askForLoginToken()
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let current = (self.myFeedDataArray?[rowIndex-1] as? [String : Any]) {
//            let dict = ["user": current]
//            pushController(withName: "MyProfileInterfaceController", context: dict)
        }
    }
    
  
 
    func fetch(secret: Secret) {
        // Load info for the logged in user.
        Endpoint.User.summary(for: secret.identifier)
            .unlocking(with: secret)
            .publish()
            .map(\.user)
            .catch { _ in Empty() }
            .assign(to: \.current, on: self)
            .store(in: &subscriptions)
        // Load the first 3 pages of the current user's followers.
        // In a real app you might want to fetch all of them.
        followers = []
        
        
        
        
        _ = Endpoint.Media.Posts.timeline(startingAt: String(startInt))
            .unlocking(with: secret)
            .task(maxLength: 10,
                  onComplete: { result in

                  },
                  onChange: { changes in
                    do {
                        if !self.shouldReloadTable {
                            return
                        }
                        
                        
                        var jsonMainDict = try changes.get().jsonRepresentation()?.convertToDictionary()
                        var feedItems = jsonMainDict?["feed_items"] as! NSArray
                        
                        self.myFeedDataArray = []
                        self.myFeedDataArray?.addObjects(from: feedItems as! [Any])
                        self.shouldReloadTable = false

                        if self.myFeedDataArray != nil {
                            var rowTypes = [""]
                            
                            for index1 in 0..<self.myFeedDataArray!.count {
                                rowTypes.append("MyFeedRowController")
                            }
                            
                            self.feedTableview.setRowTypes(rowTypes)

                            for index in 0..<self.myFeedDataArray!.count {
                                guard let controller = self.feedTableview.rowController(at: index+1) as? MyFeedRowController else { continue }
                                
                                if let currentFeed = (self.myFeedDataArray?[index] as? [String : Any])?["media_or_ad"] {
                                    controller.model = currentFeed as AnyObject
                                }
                            }
                        }
                        
                        
                        self.feedTableview.scrollToRow(at: 1)
                    } catch {
                        print("parsing fail")
                    }
            })
            .resume()
    
    
        Endpoint.Friendship.following(secret.identifier)
            .unlocking(with: secret)
            .publish()
            .prefix(3)
            .compactMap(\.users)
            .catch { _ in Empty() }
            .assign(to: \.appendFollowers, on: self)
            .store(in: &subscriptions)
    }

    @IBAction func myFeedClicked() {
        
        let userDefaults = UserDefaults(suiteName: "com.hemalM.InstaFeed.watchkitapp")!
        
        // Read/Get Data
        if let data = userDefaults.data(forKey: "userId") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                let secret = try decoder.decode(Secret.self, from: data)
                
                startInt = startInt + 1
                
                shouldReloadTable = true
                
                self.feedTableview.setRowTypes(["Reload"])
                
                fetch(secret: secret)
                
            } catch {
                print("Unable to Decode Note (\(error))")
                askForLoginToken()
            }
        } else {
            askForLoginToken()
        }
        
    }
    
    
    func askForLoginToken() {
        let action = WKAlertAction(title: "Retry", style: WKAlertActionStyle.default) {
            self.myFeedClicked()
        }
            presentAlert(withTitle: "Message", message: "Login From iPhone to continue.", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    
    @IBAction func myProfileClicked() {
        let dict = ["user": current]
        pushController(withName: "MyProfileInterfaceController", context: dict)
    }
    
    @IBAction func searchClicked() {
        pushController(withName: "FollowerController", context: nil)
    }
    
    @IBAction func followerClicked() {
        let dict = ["follower": followers]
        pushController(withName: "FollowerController", context: dict)
    }
    
}

extension InterfaceController: SwiftWatchConnectivityDelegate {
    func connectivity(_ swiftWatchConnectivity: SwiftWatchConnectivity, updatedWithTask task: SwiftWatchConnectivity.Task) {
        switch task {
        case .updateApplicationContext(let context):
            break
        case .transferUserInfo(let userInfo):
            break
        case .transferFile(let fileURL, let metadata):
            break
        case .sendMessage(let message):
            break
        case .sendMessageData(let messageData):
            SwiftWatchConnectivity.shared.sendMesssage(message: ["isSync" : true])
            
            let userDefaults = UserDefaults(suiteName: "com.hemalM.InstaFeed.watchkitapp")!
            
            do {

                let decoder = JSONDecoder()
                let secret = try decoder.decode(Secret.self, from: messageData)


                // Create JSON Encoder
                let encoder = JSONEncoder()

                // Encode Note
                let data = try encoder.encode(secret)

                userDefaults.set(data, forKey: "userId")
                userDefaults.synchronize()

                myFeedClicked()
            } catch {
                print("Unable to Encode Note (\(error))")
            }
            break
        }
    }
    
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}

extension NSDate {
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self as Date, relativeTo: Date())
    }
}
