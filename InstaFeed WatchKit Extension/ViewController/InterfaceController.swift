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
//    var appendFeedDataArray: [[String:Any]] {
//        get { [] }
//        set { myFeedDataArray?.append(contentsOf: newValue) }
//    }
    
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
        
//        getDataFromApi()
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
        presentController(withName: "NoDataInterfaceController", context: nil)
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
        
        
        
        _ = Endpoint.Media.Posts.timeline(startingAt: String(startInt))
            .unlocking(with: secret)
            .task(maxLength: 10,
                  onComplete: { result in
//                    print(result)
                    
//                    var rowTypes = [""]
                    
//                    for index1 in 0..<self.myFeedDataArray!.count {
//
//                        for index2 in 0..<self.myFeedDataArray!.count {
//                            if let user1 = ((self.myFeedDataArray?[index1] as? [String : Any])?["media_or_ad"] as? [String: Any])?["user"],
//                               let user2 = ((self.myFeedDataArray?[index2] as? [String : Any])?["media_or_ad"] as? [String: Any])?["user"] {
//
//                                if let userName1 = (user1 as? [String : Any])?["username"] as? String,
//                                   let userName2 = (user2 as? [String : Any])?["username"] as? String, userName1 == userName2 {
//                                    print(userName1 + "*******")
//                                }
//
//
//                            }
//                        }
//
////                        rowTypes.append("MyFeedRowController")
//                    }
                    
//                    self.feedTableview.setRowTypes(rowTypes)

//                    for index in 0..<self.myFeedDataArray!.count {
//                        guard let controller = self.feedTableview.rowController(at: index+1) as? MyFeedRowController else { continue }
//
//                        if let currentFeed = (self.myFeedDataArray?[index] as? [String : Any])?["media_or_ad"] {
//                            controller.model = currentFeed as AnyObject
//                        }
//
////                            if let currentFeed = self.myFeedDataArray?[index]["media_or_ad"] {
////                                print(currentFeed?[0] as! [String : AnyObject])
////                            }
//
////                            controller.model = self.myFeedDataArray?[index].value as AnyObject
////                            (with: self.myFeedDataArray?[index] ?? ["":""]) as? UserFeedModel
//                        //                            if let aDict = (self.myFeedDataArray?[index])! as NSDictionary {
//                        //                                controller.model = UserFeedModel(with: aDict)
//                        //                            }
//                        //                            controller.aDict
//
//                    }
                  },
                  onChange: { changes in
                    print(changes)
                    do {
                        if !self.shouldReloadTable {
                            return
                        }
//                        changes.get().dictionary()
                        var jsonMainDict = try changes.get().jsonRepresentation()?.convertToDictionary()
                        var feedItems = jsonMainDict?["feed_items"] as! NSArray
                        
                        self.myFeedDataArray?.addObjects(from: feedItems as! [Any])
                        self.shouldReloadTable = false
//                        if self.myFeedDataArray!.count == 0 {
//
//                        } else {
//                            for feedItem in feedItems {
//                                for index1 in 0..<self.myFeedDataArray!.count {
//                                    if let currentFeedID = ((self.myFeedDataArray?[index1] as? [String : Any])?["media_or_ad"] as? [String : Any])?["id"] as? String, let newFeedID = ((feedItem as? [String : Any])?["media_or_ad"] as? [String : Any])?["id"] as? String, newFeedID == currentFeedID  {
//    //                                    self.myFeedDataArray?.add(feedItem)
//                                        break
//                                    } else {
//                                        self.myFeedDataArray?.add(feedItem)
//                                        break
//                                    }
//                                }
//                            }
//                        }
                        
                        
//                        if !(self.myFeedDataArray?.contains(feedItems))! {
//                            self.myFeedDataArray?.addObjects(from: feedItems as! [Any])
//                        } else {
//                            return
//                        }
                        
                        
                        
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

    //                            if let currentFeed = self.myFeedDataArray?[index]["media_or_ad"] {
    //                                print(currentFeed?[0] as! [String : AnyObject])
    //                            }
                            
    //                            controller.model = self.myFeedDataArray?[index].value as AnyObject
    //                            (with: self.myFeedDataArray?[index] ?? ["":""]) as? UserFeedModel
                            //                            if let aDict = (self.myFeedDataArray?[index])! as NSDictionary {
                            //                                controller.model = UserFeedModel(with: aDict)
                            //                            }
                            //                            controller.aDict

                        }
                        
                        
//                        changes.get()["feedItems"].value.wrapped.jsonRepresentation()?.convertToDictionary()
//                        print(feedItems)
                    } catch {
                        print("parsing fail")
                    }
//                    changes.get().jsonRepresentation()
//                    do{
//                            //here dataResponse received from a network request
//                        let jsonResponse = try JSONSerialization.jsonObject(with: changes, options: .allowFragments)
//                        jsonObject(with: changes, options: [])
//                            print(jsonResponse) //Response result
//                         } catch let parsingError {
//                            print("Error", parsingError)
//                       }
                    
//                    changes.get()["feedItems"].value.wrapped.array()
//                    self.myFeedDataArray?.append(<#T##newElement: [String : Any]##[String : Any]#>) changes.get()["feedItems"].array()
//                    self.myFeedDataArray?.append(changes.get()["feedItems"].value.wrapped.array())
                    
//                    do {
//                        if let arry = try changes.get()["feedItems"].value.wrapped.array()?.wrapped {
//                            for item in arry as [AnyObject : AnyObject] {
//
//                            }
//                        }
//
//                       } catch {
//                           print("The file could parsed")
//                       }
//
                    
//                    for item in changes.get()["feedItems"].value.wrapped.array()?.wrapped {
//                        if let addItem = item
//                    }
//
//                    self.myFeedDataArray?.append([String : Any])
                        
//                        .append(contentsOf: changes.get()["feedItems"].value.wrapped.array()?[10]["mediaOrAd"] ?? [])
                    // Do something here. // changes.get()["feedItems"].value.wrapped.array()?.last
                    // changes.get()["feedItems"].value.wrapped.array()?[10]["mediaOrAd"]
            })
            .resume()
        
//        let task = Endpoint.Discover.explore()
//            .unlocking(with: secret)
//            .task(maxLength: 10,
//                  onComplete: { result in
//                    print(result)
//                  },
//                  onChange: { changes in
//                    print(changes)
//        changes.get().wrapped["items"].array()?.first
//                    // Do something here.
//            })
//            .resume()
        
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
                
                startInt = startInt + 1
                
                shouldReloadTable = true
                
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
