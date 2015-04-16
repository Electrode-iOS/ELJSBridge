//
//  THGBridgeTests.swift
//  THGBridgeTests
//
//  Created by Brandon Sneed on 3/25/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGFoundation
import THGBridge
import JavaScriptCore

class THGBridgeTests: XCTestCase {
    
    class Script: NSObject, JSExport {
        func foo() -> String {
            return "foo"
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScriptEvaluationFailure() {
        let bridge = Bridge()

        var error: NSError? = nil
        bridge.load("doSomethingStupid()", error: &error)

        XCTAssertTrue(error != nil, "An error should occur if junk javascript is evaluated!")
    }

    func testScriptDownloadScriptBadEval() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "http://theholygrail.io/testfiles/THGBridge_testdownload_bad.js")
        bridge.loadFromURL(url!) { (error) -> Void in
            if error != nil {
                failed = true
                anError = error
            }
            // signal that the block has finished.
            dispatch_semaphore_signal(semaphore)
        }

        // wait for the block to finish.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        XCTAssertTrue(failed, "This should have failed!")
        XCTAssertTrue(anError!.domain == "io.theholygrail.THGBridgeError" &&
            anError!.code == THGBridgeError.FailedToEvaluateScript.rawValue,
            "Error should be THGBridgeError.FailedToEvaluateScript!")
    }

    func testScriptDownloadScriptFileDoesNotExist() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "http://theholygrail.io/testfiles/doesnotexist.js")
        bridge.loadFromURL(url!) { (error) -> Void in
            if error != nil {
                failed = true
                anError = error
            }
            // signal that the block has finished.
            dispatch_semaphore_signal(semaphore)
        }

        // wait for the block to finish.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        XCTAssertTrue(failed, "This should have failed!")
        XCTAssertTrue(anError!.domain == "io.theholygrail.THGBridgeError" &&
            anError!.code == THGBridgeError.FileDoesNotExist.rawValue,
            "Error should be THGBridgeError.FileDoesNotExist!")
    }

    func testScriptDownloadScriptWorks() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "http://theholygrail.io/testfiles/THGBridge_testdownload_good.js")
        bridge.loadFromURL(url!) { (error) -> Void in
            if error != nil {
                failed = true
                anError = error
            }
            // signal that the block has finished.
            dispatch_semaphore_signal(semaphore)
        }

        // wait for the block to finish.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        XCTAssertTrue(failed == false, "This shouldn't have failed!")
        XCTAssertTrue(anError == nil, "There should be no errors!")

        let testFunction = bridge.contextValueForName("test")
        if testFunction.isUndefined() {
            println("you moron.")
        }
        let result = testFunction.callWithArguments([2, 2])

        let global = bridge.context.globalObject
        println("global = \(global.toDictionary())")


        XCTAssertTrue(result.isNumber(), "the javascript function should've returned a number!")
        XCTAssertTrue(result.toInt32() == 4, "the javascript function should've returned a value of 3!")
    }


    func testPerformanceExampleJS() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "http://theholygrail.io/testfiles/THGBridge_testdownload_good.js")
        bridge.loadFromURL(url!) { (error) -> Void in
            if error != nil {
                failed = true
                anError = error
            }
            // signal that the block has finished.
            dispatch_semaphore_signal(semaphore)
        }

        // wait for the block to finish.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        XCTAssertTrue(failed == false, "This shouldn't have failed!")
        XCTAssertTrue(anError == nil, "There should be no errors!")

        let testFunction = bridge.context.objectForKeyedSubscript("test")
        let result = testFunction.callWithArguments([2, 2])

        XCTAssertTrue(result.isNumber(), "the javascript function should've returned a number!")
        XCTAssertTrue(result.toInt32() == 4, "the javascript function should've returned a value of 3!")

        // start up our serial queue
        let serialQueue = dispatch_queue_create("blah", DISPATCH_QUEUE_SERIAL)

        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for index in 0..<1000 {
                dispatch_async(serialQueue, { () -> Void in
                    let result = testFunction.callWithArguments([1, index])
                    println("result = \(result.toInt32())")
                })

            }

            dispatch_semaphore_signal(semaphore)
        }

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }

    func testPerformanceExampleSwift() {

        func addTwoNumbers(a: Int, b: Int) -> Int {
            return a + b
        }

        let semaphore = dispatch_semaphore_create(0)

        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for index in 0..<10000 {
                let result = addTwoNumbers(2, 2)
            }

            dispatch_semaphore_signal(semaphore)
        }

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    // MARK: Export API Tests
    
    func testAddExport() {
        let name = "testExport"
        let export = Script()
        let bridge = Bridge()
        bridge.addExport(export, name: name)
        
        XCTAssert(bridge.exports[name] === export)
        XCTAssert(bridge.contextValueForName(name).toObject() === export)
    }
    
    func testExportsBetweenContextChanges() {
        let name = "testExport"
        let export = Script()
        let bridge = Bridge()
        bridge.addExport(export, name: name)
        
        XCTAssert(bridge.exports[name] === export)
        XCTAssert(bridge.contextValueForName(name).toObject() === export)
        
        bridge.context = JSContext(virtualMachine: JSVirtualMachine())
        
        XCTAssert(bridge.contextValueForName(name).toObject() === export)
    }
    
    func testGetWebViewJavaScriptContext() {
        let webView = UIWebView(frame: CGRectZero)
        let context = webView.javaScriptContext
        XCTAssert(context != nil)
    }
    
}
