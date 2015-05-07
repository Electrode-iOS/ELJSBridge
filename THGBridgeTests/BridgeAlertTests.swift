//
//  BridgeAlertTests.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 5/5/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGBridge
import JavaScriptCore

class BridgeAlertTests: XCTestCase {

    static let testActions: [[String: AnyObject]] = [["id": "robin", "label": "Sir Robin"], ["id": "lancelot", "label": "Sir Lancelot"]]
    static let testOptions: [String: AnyObject] = ["title": "You must answer three questions.", "message": "What is your name?", "actions": testActions]
    
    func testAlertControllerWithOptions() {
        let bridge = Bridge()
        let callback = JSValue()
        let alertViewController = BridgeAlert.alertControllerWithOptions(BridgeAlertTests.testOptions, callback: callback)
        
        XCTAssertEqual(alertViewController.actions.count, 2)
        
        var index = 0
        for action in alertViewController.actions {
            
            XCTAssert(action is UIAlertAction)
            
            if let action = action as? UIAlertAction,
                let label = BridgeAlertTests.testActions[index]["label"] as? String {
                XCTAssertEqual(action.title, label)
            }
            
            index++
        }
    }
}
