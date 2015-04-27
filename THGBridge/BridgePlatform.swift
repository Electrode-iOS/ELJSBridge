//
//  BridgePlatform.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

private let bridgePlatformExportName = "NativeBridge"

@objc protocol BridgePlatformProtocol: JSExport {
    var navigation: BridgeNavigation {get}
    func updatePageState(options: [String: AnyObject])
    func log(value: AnyObject)
}

@objc class BridgePlatform: WebViewControllerScript, BridgePlatformProtocol {
    var navigation = BridgeNavigation()
    
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

// MARK: - WebViewController Integration

public extension WebViewController {
    
    static func WithBridgePlatform() -> WebViewController {
        let webViewController = WebViewController()
        webViewController.bridge.addExport(BridgePlatform(), name: bridgePlatformExportName)
        return webViewController
    }
}

// MARK: - Bridge Integration

extension Bridge {
    
    var platform: BridgePlatform? {
        return contextValueForName(bridgePlatformExportName).toObject() as? BridgePlatform
    }
}
