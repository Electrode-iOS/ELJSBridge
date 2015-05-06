//
//  BridgePlatform.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore


@objc protocol PlatformJSExport: JSExport {
    var navigation: BridgeNavigation {get}
    func updatePageState(options: [String: AnyObject])
    func log(value: AnyObject)
}

@objc public class BridgePlatform: WebViewControllerScript, PlatformJSExport {
    var navigation = BridgeNavigation()
    static let exportName = "NativeBridge"

    override weak var parentWebViewController: WebViewController? {
        didSet {
            navigation.parentWebViewController = parentWebViewController
        }
    }
    
    func updatePageState(options: [String: AnyObject]) {
        
        if let title = options["title"] as? String {
            parentWebViewController?.title = title
        }
    }
    
    func log(value: AnyObject) {
        println("BridgeOfDeath: \(value)")
    }
}

// MARK: - ShareJSExport

extension BridgePlatform: ShareJSExport {
    
    func share(options: [String: AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            if let activityViewController = BridgeShareActivity.activityViewControllerWithOptions(options) {
                self.parentWebViewController?.presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - DialogJSExport

extension BridgePlatform: DialogJSExport {
    
    func dialog(options: [String: AnyObject], _ callback: JSValue) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = BridgeAlert.alertControllerWithOptions(options, callback: callback)
            self.parentWebViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - WebViewController Integration

public extension WebViewController {
    
    static func WithBridgePlatform() -> WebViewController {
        let webViewController = WebViewController()
        webViewController.bridge.addExport(BridgePlatform(), name: BridgePlatform.exportName)
        return webViewController
    }
}

// MARK: - Bridge Integration

extension Bridge {
    
    var platform: BridgePlatform? {
        return contextValueForName(BridgePlatform.exportName).toObject() as? BridgePlatform
    }
}
