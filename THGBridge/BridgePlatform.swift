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
}

@objc class BridgePlatform: WebViewControllerScript, BridgePlatformProtocol {
    var navigation = BridgeNavigation()
    
    override weak var parentWebViewController: WebViewController? {
        didSet {
            navigation.parentWebViewController = parentWebViewController
        }
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
