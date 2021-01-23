//
//  MyProfileInterfaceController.swift
//  InstaFeed WatchKit Extension
//
//  Created by Hemal on 23/01/2021.
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

class MyProfileInterfaceController: WKInterfaceController {

    var myProfile: User? {
        didSet {
            profileImage.kf.setImage(with: myProfile?.thumbnail)
            
            userName.setText(myProfile?.username)
            nameLabel.setText(myProfile?.name)
            
            if let postCount = myProfile?.counter?.posts {
                postCountLabel.setText("Posts : \(postCount)")
            }
            if let followersCount = myProfile?.counter?.followers {
                followerCountLabel.setText("Followers : \(followersCount)")

            }
            if let followingCount = myProfile?.counter?.following {
                followingCountLabel.setText("Following : \(followingCount)")
            }
            
            if let tagsCount = myProfile?.counter?.tags {
                taggedLabel.setText("Tags : \(tagsCount)")
            }
        }
    }
    
    @IBOutlet weak var profileImage: WKInterfaceImage!
    @IBOutlet weak var userName: WKInterfaceLabel!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var postCountLabel: WKInterfaceLabel!
    @IBOutlet weak var followerCountLabel: WKInterfaceLabel!
    @IBOutlet weak var followingCountLabel: WKInterfaceLabel!
    @IBOutlet weak var taggedLabel: WKInterfaceLabel!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        
        let dict = context as! Dictionary<String, Any>
        myProfile = dict["user"] as? User
        
        let userDefaults = UserDefaults(suiteName: "com.hemalM.InstaFeed.watchkitapp")!
        
        var secret : Secret
        
        if let data = userDefaults.data(forKey: "userId") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                secret = try decoder.decode(Secret.self, from: data)
                fetch(secret: secret)
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        
//        Endpoint.User.summary(for: myProfile?.id ?? "")
//            .unlocking(with: secret)
//            .publish()
//            .map(\.user)
//            .catch { _ in Empty() }
//            .assign(to: \.myProfile, on: self)
//            .store(in: &subscriptions)
        
      
        
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func fetch(secret: Secret) {
        Endpoint.User.summary(for: myProfile?.identifier ?? "")
            .unlocking(with: secret)
            .publish()
            .map(\.user)
            .catch { _ in Empty() }
            .assign(to: \.myProfile, on: self)
            .store(in: &subscriptions)
    }
}
