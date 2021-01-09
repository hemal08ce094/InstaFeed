//
//  ExtensionDelegate.swift
//  InstaFeed WatchKit Extension
//
//  Created by Hemal on 29/12/2020.
//


import WatchKit
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // MARK: - WKExtensionDelegate -
    
    func applicationDidFinishLaunching() {
        NSHomeDirectory()
//        setupObservations()
    }
    

    
}

private extension ExtensionDelegate {
    
    
    private func reloadAllComplications() {
        CLKComplicationServer.sharedInstance().activeComplications?.forEach {
            CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
        }
    }
    
}
