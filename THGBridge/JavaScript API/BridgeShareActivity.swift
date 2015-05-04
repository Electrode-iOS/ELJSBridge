//
//  BridgeShareActivity.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 5/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol ShareJSExport: JSExport {
    func share(options: [String: AnyObject])
}

struct BridgeShareActivity {
    
    static func activityViewControllerWithOptions(options: [String: AnyObject]) -> UIActivityViewController? {
        if let items = shareItemsFromOptions(options) {
            return UIActivityViewController(activityItems: items, applicationActivities: nil)
        }
        
        return nil
    }
    
    private static func shareItemsFromOptions(options: [String: AnyObject]) -> [AnyObject]? {
        if let message = options["message"] as? String,
            let url = options["url"] as? String {
                return [url, message]
        }
        
        return nil
    }
}
