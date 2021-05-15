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
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    

//    var completion: ((Secret) -> Void)?
//    /// The web view.
//    var webView: WKWebView? {
//        didSet {
//            guard let webView = webView else { return }
//            webView.frame = view.frame
//            view.addSubview(webView)
//        }
//    }
    @IBOutlet weak var syncButton: UIButton!
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
            
            // Read/Get Data
            if let data = userDefaults.data(forKey: "userId") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    let secret = try decoder.decode(Secret.self, from: data)
                    SwiftWatchConnectivity.shared.sendMesssageData(data: data)
                    self.syncButton.setTitle("Open InstaFeed App in your watch and click here", for: .normal)
                } catch {
                    print("Unable to Decode Note (\(error))")
                    askForLoginToken()
                }
            } else {
                askForLoginToken()
            }
        } else {
            let alertController = UIAlertController(title: "Message", message:
                                                        "Couldnt communicate to your Apple watch, Please restart your phone or watch", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "okay", style: .default,handler: { action in
                  
             }))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Client.default = .current ?? .iPhone11ProMax
        
        let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
        
        // Read/Get Data
        if let data = userDefaults.data(forKey: "userId") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                let secret = try decoder.decode(Secret.self, from: data)
                
                syncButton.setTitle(" Click here to Sync with watch ", for: .normal)
            } catch {
                print("Unable to Decode Note (\(error))")
                
                syncButton.setTitle(" Click here to Login", for: .normal)
            }
        } else {
            syncButton.setTitle(" Click here to Login ", for: .normal)
        }
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        SwiftWatchConnectivity.shared.delegate = self
    }
    
    func askForLoginToken() {
        DispatchQueue.main.async {
            self.present(AuthenticationViewController(nibName: "AuthenticationViewController", bundle: Bundle.main), animated: true) {
                self.syncButton.setTitle("Click here to Sync with watch ", for: .normal)
            }}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func SyncClicked(_ sender: Any) {
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
        
        // Read/Get Data
        if let data = userDefaults.data(forKey: "userId") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                let secret = try decoder.decode(Secret.self, from: data)
                SwiftWatchConnectivity.shared.sendMesssageData(data: data)
                
                self.syncButton.setTitle("Open InstaFeed App in your watch and click here", for: .normal)
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
            if ((message["isSync"] as? Bool) == true) {
                // Synced success
                syncButton.setTitle("Your data has been Synced with Watch Securely", for: .normal)
            }
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
