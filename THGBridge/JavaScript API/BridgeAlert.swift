//
//  BridgeAlert.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 5/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

public struct BridgeAlert {
    
    public static func alertControllerWithOptions(options: [String: AnyObject], callback: JSValue) -> UIAlertController {
        let title = options["title"] as? String
        let message = options["message"] as? String
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if let actions = options["actions"] as? [[String: AnyObject]] {
            for action in actions {
                if let alertAction = alertActionWithOptionAction(action, callback: callback) {
                    alertController.addAction(alertAction)
                }
            }
        }
        
        return alertController
    }
    
    private static func alertActionWithOptionAction(optionAction: [String: AnyObject], callback: JSValue) -> UIAlertAction? {
        if let actionID = optionAction["id"] as? String,
            let actionLabel = optionAction["label"] as? String {
                let alertAction = UIAlertAction(title: actionLabel, style: .Default) { (action) in
                    callback.callWithData(actionID)
                }
                
                return alertAction
        }
        
        return nil
    }
}
