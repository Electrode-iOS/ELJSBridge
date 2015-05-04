//
//  BridgeDialog.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/29/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol DialogJSExport: JSExport {
    func dialog(options: [String: AnyObject], _ callback: JSValue)
}
