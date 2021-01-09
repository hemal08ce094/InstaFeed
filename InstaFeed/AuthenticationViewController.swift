//
//  AuthenticationViewController.swift
//  InstaFeed
//
//  Created by Hemal on 30/12/2020.
//

import UIKit
import WebKit
import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto
import WatchConnectivity


class AuthenticationViewController: UIViewController {
   
    

    var completion: ((Secret) -> Void)?
    /// The web view.
    var webView: WKWebView? {
        didSet {
            guard let webView = webView else { return }
            webView.frame = view.frame
            view.addSubview(webView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults(suiteName: "group.com.hemalM.InstaFeed")!
             
        
        // Authenticate.
    
        WebViewAuthenticator(storage: ComposableRequestCrypto.KeychainStorage<Secret>()) {
            self.webView = $0
        }.authenticate { [weak self] in
            switch $0 {
            case .failure(let error): print(error.localizedDescription)
            case .success(let secret):
                self?.completion?(secret)
                do {
                    // Create JSON Encoder
                    let encoder = JSONEncoder()

                    // Encode Note
                    let data = try encoder.encode(secret)

                    userDefaults.set(data, forKey: "userId")
                    userDefaults.synchronize()

                } catch {
                    print("Unable to Encode Note (\(error))")
                }

                self?.dismiss(animated: true, completion: nil)
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
