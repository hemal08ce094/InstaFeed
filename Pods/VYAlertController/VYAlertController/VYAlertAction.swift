//
//  VYAlertAction.swift
//  VYAlertController
//
//  Created by Vladyslav Yakovlev on 10/9/18.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

extension VYAlertAction {
    
    public enum Style {
        
        case normal
        
        case cancel
        
        case destructive
    }
}

public final class VYAlertAction {
    
    public let title: String
    
    public let style: VYAlertAction.Style
    
    let handler: ((VYAlertAction) -> ())?
    
    public init(title: String, style: VYAlertAction.Style, handler: ((VYAlertAction) -> ())? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}


