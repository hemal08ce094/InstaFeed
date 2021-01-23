//
//  CurrencyRowController.swift
//  CryptoWatcher WatchKit Extension
//
//  Created by Hemal on 11/12/2020.
//

import WatchKit

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto
import WatchConnectivity
import SwiftWatchConnectivity
import Kingfisher

class FollowRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var detailLabel: WKInterfaceLabel!
    @IBOutlet var currencyImage: WKInterfaceImage!

    var model: User? {
        didSet {
            guard let model = model else { return }

            titleLabel.setText(model.name)
            detailLabel.setText(model.username)
            currencyImage.kf.setImage(with: model.thumbnail)
        }
    }
    
    
    override init() {

    }
}
