//
//  BridgePlatformTests.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 5/5/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGBridge

class BridgePlatformTests: XCTestCase {

    func testUpdateState() {
        let webController = WebViewController.WithBridgePlatform()
        let title = "What is your name?"
        let options = "{title: '\(title)'}"
        let updateScript = "\(BridgePlatform.exportName).updatePageState(\(options))"
        webController.bridge.context.evaluateScript(updateScript)
        
        XCTAssertNotNil(webController.title)
        XCTAssertEqual(title, webController.title!)
    }
    
    func testWithBridgePlatform() {
        let webController = WebViewController.WithBridgePlatform()
        let platform: AnyObject = webController.bridge.contextValueForName(BridgePlatform.exportName).toObject()
        
        XCTAssert(platform is BridgePlatform)
    }
    
    func testPlatformProperty() {
        let bridge = Bridge()
        
        let platform = BridgePlatform(parentViewController: WebViewController())
        bridge.addExport(platform, name: BridgePlatform.exportName)

        
        XCTAssertNotNil(bridge.platform)
        XCTAssertEqual(bridge.platform!, platform)
    }
    
    func testDialogExport() {
        let webController = WebViewController.WithBridgePlatform()
        let result = webController.bridge.context.evaluateScript("NativeBridge.dialog")
        XCTAssert(result.isObject())
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testShareExport() {
        let webController = WebViewController.WithBridgePlatform()
        let result = webController.bridge.context.evaluateScript("NativeBridge.share")
        
        XCTAssert(result.isObject())
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationExport() {
        let webController = WebViewController.WithBridgePlatform()
        let result = webController.bridge.context.evaluateScript("NativeBridge.navigation")
        XCTAssert(result.isObject())
        XCTAssert(result.toObject() is BridgeNavigation)
    }
    
    func testDidSetParentViewControllers() {
        let webController = WebViewController.WithBridgePlatform()
        let newWebController = WebViewController()
        let bridge = webController.bridge
        
        bridge.platform?.parentViewController = newWebController
        let navigation = bridge.context.evaluateScript("NativeBridge.navigation").toObject() as! BridgeNavigation
        
        XCTAssertEqual(navigation.parentViewController!, newWebController)
    }
    
    func testExportName() {
        XCTAssertEqual(BridgePlatform.exportName, "NativeBridge")
    }
}
