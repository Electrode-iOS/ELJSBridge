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

@objc class BridgeNavigation: WebViewControllerScript, BridgeNavigationProtocol {
    
    func animateForward() {
        parentWebViewController?.pushWebViewController()
    }
    
    func animateBackward() {
        parentWebViewController?.popWebViewController()
    }
}
