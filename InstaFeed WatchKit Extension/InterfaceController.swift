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
    
    var current: User?
    var followers: [User]?

    var myFeedDataArray: [Swiftagram.PaginatedType.Type]?
    var aMedia: Swiftagram.Media.Collection?
    
    var appendFollowers: [User] {
        get { [] }
        set { followers?.append(contentsOf: newValue) }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        SwiftWatchConnectivity.shared.delegate = self
        
        myFeedClicked()
        
        getDataFromApi()
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
    
    func askForLoginToken() {
        // show empty controller saying authenticate again from iPhone.
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
        myFeedDataArray = []
        
        
        // Perform the request.
//        Endpoint.User.summary(for: secret.identifier)
//            .unlocking(with: secret)
//            .task {result in
//                // Do something here
//
//                print(result)
//            };).resume() // Strongly referenced by default, no need to worry about it.
        
        let task = Endpoint.Discover.explore()
            .unlocking(with: secret)
            .task(maxLength: 10,
                  onComplete: { result in
                    print(result)
                  },
                  onChange: { changes in
                    print(changes)
                    // Do something here.
            })
            .resume()
        
//        Endpoint.Media.summary(for: secret.identifier)
//            .unlocking(with: secret)
//            .publish()
//            .prefix(3)
//            .catch { _ in Empty() }
//            .assign(to: \.current, on: self)
//            .store(in: &subscriptions)
        
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
                
                fetch(secret: secret)
                
            } catch {
                print("Unable to Decode Note (\(error))")
                askForLoginToken()
            }
        } else {
            askForLoginToken()
        }
        
    }
    @IBAction func myProfileClicked() {
        pushController(withName: "FollowerController", context: nil)
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

            } catch {
                print("Unable to Encode Note (\(error))")
            }
            break
        }
    }
    
}

extension InterfaceController {
    func getDataFromApi() {
        var rowTypes = [""]
        
        for _ in 0..<10 {
            rowTypes.append("MyFeedRowController")
        }
        
        self.feedTableview.setRowTypes(rowTypes)

        for index in 0..<10 {
            guard let controller = self.feedTableview.rowController(at: index+1) as? FollowRowController else { continue }
//            controller.model = followers?[index]
        }
    }
}
