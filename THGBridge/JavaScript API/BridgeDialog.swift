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

@objc class BridgeDialog: NSObject, UIAlertViewDelegate {
    var alert: BridgeAlert?
    var callback: JSValue?
    
    func showWithOptions(options: [String: AnyObject], callback: JSValue) {
        alert = BridgeAlert(options: options)
        self.callback = callback
        
        if let alert = alert {
            let alertView = alert.alertView()
            alertView.delegate = self
            alertView.show()
        }
    }
    
    // MARK: UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let selectedAction = alert?.actions[buttonIndex] {
            callback?.callWithData(selectedAction.actionID)
        }
    }
}

struct BridgeAlert {
    
    struct Action {
        let label: String
        let actionID: String
    }
    
    let title: String?
    let message: String?
    let actions: [Action]
    
    init(options: [String: AnyObject]) {
        
        self.title = options["title"] as? String
        self.message = options["message"] as? String
        
        var theActions = [Action]()
        
        if let actions = options["actions"] as? [[String: AnyObject]] {
            for action in actions {
                if let actionID = action["id"] as? String,
                    let actionLabel = action["label"] as? String {
                        let alertAction = Action(label: actionLabel, actionID: actionID)
                        theActions.append(alertAction)
                }
            }
        }
        
        actions = theActions
    }
    
    // MARK: UIAlertView
    
    func alertView() -> UIAlertView {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        
        for action in actions {
            alert.addButtonWithTitle(action.label)
        }
        
        return alert
    }
}
