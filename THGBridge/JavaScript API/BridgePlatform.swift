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
    var navigation: BridgeNavigation
    public static let exportName = "NativeBridge"
    
    public override init(parentViewController: WebViewControllerType) {
        self.navigation = BridgeNavigation(parentViewController: parentViewController)
        super.init(parentViewController: parentViewController)
    }

    override public weak var parentViewController: UIViewController? {
        didSet {
            navigation.parentViewController = parentViewController
        }
    }
    
    func updatePageState(options: [String: AnyObject]) {
        
        if let title = options["title"] as? String {
            parentViewController?.title = title
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
                self.parentViewController?.presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - DialogJSExport

extension BridgePlatform: DialogJSExport {
    
    func dialog(options: [String: AnyObject], _ callback: JSValue) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = BridgeAlert.alertControllerWithOptions(options, callback: callback)
            self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - WebViewController Integration

public extension WebViewController {
    
    static func WithBridgePlatform() -> WebViewController {
        let webViewController = WebViewController()
        let platform = BridgePlatform(parentViewController: webViewController)
        webViewController.bridge.addExport(platform, name: BridgePlatform.exportName)
        return webViewController
    }
}

// MARK: - Bridge Integration

public extension Bridge {
    
    public var platform: BridgePlatform? {
        return contextValueForName(BridgePlatform.exportName).toObject() as? BridgePlatform
    }
}
