//
//  BridgeNavigation.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

protocol BridgeNavigationViewController: class {
    func nextViewController() -> UIViewController
}

@objc protocol BridgeNavigationJSExport: JSExport {
    func animateBackward()
    func animateForward()
}

@objc public class BridgeNavigation: WebViewControllerScript, BridgeNavigationJSExport {
    
    weak var bridgeNavigationViewController: BridgeNavigationViewController? {
        return parentViewController as? BridgeNavigationViewController
    }
    
    func animateForward() {
        dispatch_async(dispatch_get_main_queue()) {
            if let viewController = self.bridgeNavigationViewController?.nextViewController() {
                self.parentViewController?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func animateBackward() {
        dispatch_async(dispatch_get_main_queue()) {
            self.parentViewController?.navigationController?.popViewControllerAnimated(true)
        }
    }
}
