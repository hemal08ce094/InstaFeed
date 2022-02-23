//
//  NetworkManager.swift
//  InstaSaver
//
//  Created by Vyacheslav Bakinskiy on 1/18/21.
//

import Alamofire

struct NetworkManager {
    static let shared = NetworkManager()
    static let reachabilityNotification = "reachabilityNotification"
    
    private let reachabilityManager = NetworkReachabilityManager()!
    
    public var isNetworkAvailable: Bool {
        reachabilityManager.isReachable
    }
    
    public func listenNetworkReachability() {
        reachabilityManager.startListening(onUpdatePerforming: { _ in
            NotificationCenter.default.post(name: NSNotification.Name(NetworkManager.reachabilityNotification), object: nil)
        })
    }
    
    static func showNetworkReachabilityAlert(vc: UIViewController, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: NSLocalizedString("Check your network connection", comment: ""),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            if let completion: () -> Void = completion {
                completion()
            }
        }
        alert.addAction(okAction)
        alert.view.tintColor = UIColor(named: "customBlack")
        vc.present(alert, animated: true, completion: nil)
    }
}
