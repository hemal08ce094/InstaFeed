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
import StoreKit
import VYAlertController

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
    @IBOutlet weak var pasteButton: UIButton!
    
    var productsArray = [SKProduct]()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed1")!
            
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
        inappInit()
        Client.default = .current ?? .iPhone11ProMax
        pasteButton.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        
        let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed1")!
        
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
    
    func inappInit() {
        pasteButton.isEnabled = false
        PKIAPHandler.shared.isLogEnabled = true
        PKIAPHandler.shared.setProductIds(ids: ["wi_19.9_30d"])
        

        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            self?.productsArray = products
            DispatchQueue.main.async {
                self?.pasteButton.isEnabled = true
            }
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
        
        continueFlow()
        
       func continueFlow() {
            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = self
                session.activate()
            }
            
            let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed1")!
            
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

extension ViewController {
    @objc private func pasteButtonTapped() {
        
        buttonclicked()
        
//        DispatchQueue.main.async {
//            let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
//
//            if userDefaults.bool(forKey: "inApp") == true {
//                buttonclicked()
//            } else {
//                PKIAPHandler.shared.purchase(product: self.productsArray[0]) { (alert, product, transaction) in
//                    if let tran = transaction, let prod = product {
//                        //use transaction details and purchased product as you want
//                        if alert == .purchased || alert == .restored {
//                            buttonclicked()
//                            userDefaults.set(true, forKey: "inApp")
//                            userDefaults.synchronize()
//                        } else {
//                            userDefaults.set(false, forKey: "inApp")
//                            userDefaults.synchronize()
//                        }
//                    }
//                }
//            }
//        }
        
        func restorePurchase() {
            PKIAPHandler.shared.restorePurchase()
        }
        
//        func paymentQueueRestoreCompletedTransactionsFinishe
        
        
        func buttonclicked() {
            if let link = UIPasteboard.general.string {
                checkLink(link)
            } else {
                self.showMessage(msg: "Copy the post link first")
            }
        }
        
    }
    
    private func checkLink(_ link: String) {
        guard let activeLink = InstaService.checkLink(link) else {
            showInvalidLinkMessage()
            return
        }
        
        changeButtonTitle()
        InstaService.getMediaPost(with: activeLink) { post in
            self.setInitialButtonTitle()
            guard let post = post else {
                self.showConnectionErrorMessage()
                return
            }
            
            self.showMediaPost(post)
        }
    }
    
    private func showMediaPost(_ post: Post) {
        let previewVC = post.isVideo ? VideoPreviewVC() : ImagePreviewVC()
        previewVC.post = post
        present(previewVC, animated: true)
    }
    
    private func changeButtonTitle() {
        pasteButton.setTitle("Process...", for: .normal)
        pasteButton.isUserInteractionEnabled = false
    }
    
    private func setInitialButtonTitle() {
        pasteButton.setTitle("Click Here To Paste Link", for: .normal)
        pasteButton.isUserInteractionEnabled = true
    }
    
    private func showConnectionErrorMessage() {
        self.showMessage(msg: "Connection Error")
    }
    
    private func showInvalidLinkMessage() {
        self.showMessage(msg: "Invalid Link")
    }
    
    func showMessage(msg:String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
