//
//  BridgePlatform.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol BridgePlatformProtocol: JSExport {
    var navigation: BridgeNavigation? {get}
}

@objc class BridgePlatform: NSObject, BridgePlatformProtocol {
    var navigation: BridgeNavigation?
}

let bridgePlatformExportName = "NativeBridge"

extension Bridge {
    
    var platform: BridgePlatform? {
        return contextValueForName(bridgePlatformExportName).toObject() as? BridgePlatform
    }
    
    func addPlatformExportIfNeeded() {
        if platform == nil {
            let platform = BridgePlatform()
            platform.navigation = BridgeNavigation()
            addExport(platform, name: bridgePlatformExportName)
        }
    }
}
