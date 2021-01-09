//
//  ViewController.swift
//  InstaFeed
//
//  Created by Hemal on 29/12/2020.
//

import UIKit

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto
import WatchConnectivity
import SwiftWatchConnectivity

class ViewController: UIViewController {

//    var completion: ((Secret) -> Void)?
//    /// The web view.
//    var webView: WKWebView? {
//        didSet {
//            guard let webView = webView else { return }
//            webView.frame = view.frame
//            view.addSubview(webView)
//        }
//    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
            
            // Read/Get Data
            if let data = userDefaults.data(forKey: "userId") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    let secret = try decoder.decode(Secret.self, from: data)
                } catch {
                    print("Unable to Decode Note (\(error))")
                    askForLoginToken()
                }
            } else {
                askForLoginToken()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Client.default = .current ?? .iPhone11ProMax
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        SwiftWatchConnectivity.shared.delegate = self
    }
    
    func askForLoginToken() {
        DispatchQueue.main.async {
            self.present(AuthenticationViewController(nibName: "AuthenticationViewController", bundle: Bundle.main), animated: true) {
                
            }}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func SyncClicked(_ sender: Any) {
        let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
        
        // Read/Get Data
        if let data = userDefaults.data(forKey: "userId") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                let secret = try decoder.decode(Secret.self, from: data)
                SwiftWatchConnectivity.shared.sendMesssageData(data: data)
               
            } catch {
                print("Unable to Decode Note (\(error))")
                askForLoginToken()
            }
        } else {
            askForLoginToken()
        }
    }
    
}


extension ViewController: SwiftWatchConnectivityDelegate {
    func connectivity(_ swiftWatchConnectivity: SwiftWatchConnectivity, updatedWithTask task: SwiftWatchConnectivity.Task) {
        switch task {
        case .sendMessage(let message):
            break
        case .transferUserInfo(let userInfo):
            break
        case .updateApplicationContext(let context):
            break
        case .transferFile(_, _):
            break
        case .sendMessageData(_):
            break
        }
    }
}
