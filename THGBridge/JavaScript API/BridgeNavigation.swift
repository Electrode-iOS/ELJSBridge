//
//  BridgeNavigation.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol BridgeNavigationJSExport: JSExport {
    func animateBackward()
    func animateForward()
}

@objc class BridgeNavigation: WebViewControllerScript, BridgeNavigationJSExport {
    
    func animateForward() {
        dispatch_async(dispatch_get_main_queue()) {
            parentWebViewController?.pushWebViewController()
        }
    }
    
    func animateBackward() {
        dispatch_async(dispatch_get_main_queue()) {
            parentWebViewController?.popWebViewController()
        }
    }
}
