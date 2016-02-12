//
//  ELJSBridgeTests.swift
//  ELJSBridgeTests
//
//  Created by Brandon Sneed on 3/25/15.
//  Copyright (c) WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
import ELFoundation
import ELJSBridge
import JavaScriptCore

class ELJSBridgeTests: XCTestCase {
    
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

        do {
            try bridge.load("doSomethingStupid()")
        } catch {
            return
        }
        XCTAssert(true, "An error should occur if junk javascript is evaluated!")
    }

    func testScriptDownloadScriptBadEval() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "https://raw.githubusercontent.com/Electrode-iOS/ELJSBridge/master/ELJSBridgeTests/TestFiles/ELJSBridge_testdownload_bad.js")
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
        XCTAssertTrue(anError!.domain == "com.walmartlabs.ELJSBridgeError" &&
            anError!.code == ELJSBridgeError.FailedToEvaluateScript.rawValue,
            "Error should be ELJSBridgeError.FailedToEvaluateScript!")
    }

    func testScriptDownloadScriptFileDoesNotExist() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "https://raw.githubusercontent.com/Electrode-iOS/ELJSBridge/master/ELJSBridgeTests/TestFiles/doesnotexist.js")
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
        XCTAssertTrue(anError!.domain == "com.walmartlabs.ELJSBridgeError" &&
            anError!.code == ELJSBridgeError.FileDoesNotExist.rawValue,
            "Error should be ELJSBridgeError.FileDoesNotExist!")
    }

    func testScriptDownloadScriptWorks() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "https://raw.githubusercontent.com/Electrode-iOS/ELJSBridge/master/ELJSBridgeTests/TestFiles/ELJSBridge_testdownload_good.js")
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
        if testFunction.isUndefined {
            print("you moron.")
        }
        let result = testFunction.callWithArguments([2, 2])

        let global = bridge.context.globalObject
        print("global = \(global.toDictionary())")


        XCTAssertTrue(result.isNumber, "the javascript function should've returned a number!")
        XCTAssertTrue(result.toInt32() == 4, "the javascript function should've returned a value of 3!")
    }


    func testPerformanceExampleJS() {
        let bridge = Bridge()
        var failed = false
        var anError: NSError? = nil

        let semaphore = dispatch_semaphore_create(0)

        let url = NSURL(string: "https://raw.githubusercontent.com/Electrode-iOS/ELJSBridge/master/ELJSBridgeTests/TestFiles/ELJSBridge_testdownload_good.js")
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

        XCTAssertTrue(result.isNumber, "the javascript function should've returned a number!")
        XCTAssertTrue(result.toInt32() == 4, "the javascript function should've returned a value of 3!")

        // start up our serial queue
        let serialQueue = dispatch_queue_create("blah", DISPATCH_QUEUE_SERIAL)

        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for index in 0..<1000 {
                dispatch_async(serialQueue, { () -> Void in
                    let result = testFunction.callWithArguments([1, index])
                    print("result = \(result.toInt32())")
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
            for _ in 0..<10000 {
                let _ = addTwoNumbers(2, b: 2)
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
    
    func testExample() {
        let bridge = Bridge()
        bridge.context.evaluateScript("var question = 'What is your name?'")
        let question: JSValue = bridge.contextValueForName("question") //bridge.context.evaluateScript("question")
        print(question) // "What is your name?"
        
    }
}
