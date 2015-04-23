//
//  BridgeNavigation.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol BridgeNavigationProtocol: JSExport {
    func animateBackward()
    func animateForward()
}

@objc class BridgeNavigation: NSObject, BridgeNavigationProtocol {
    weak var webNavigator: WebViewControllerNavigator?
    
    func animateBackward() {
        webNavigator?.animateBackward()
    }
    
    func animateForward() {
        webNavigator?.animateForward()
    }
}
