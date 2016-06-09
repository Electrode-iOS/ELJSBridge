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
    
    func test_load_throwsFailedToEvaluateScriptErrorWithBogusScript() {
        let bridge = Bridge()

        do {
            try bridge.load("doSomethingStupid()")
        } catch ELJSBridgeError.FailedToEvaluateScript {
        } catch _ {
            XCTFail("Expected to fail with error ELJSBridgeError.FailedToEvaluateScript")
        }
    }

    func test_loadFromFile_throwsFailedToEvaluateScriptErrorWithBogusFile() {
        let bridge = Bridge()
        let path = NSBundle(forClass: self.dynamicType).pathForResource("ELJSBridge_testdownload_bad", ofType: "js")!
        
        do {
            try bridge.loadFromFile(path)
        } catch ELJSBridgeError.FailedToEvaluateScript {
        } catch _ {
            XCTFail("Expected loadFromFile to fail with error ELJSBridgeError.FailedToEvaluateScript")
        }
    }

    func test_loadFromFile_throwsFileDoesNotExistErrorWhenFileIsMissing() {
        let bridge = Bridge()
        
        do {
            try bridge.loadFromFile("/path/to/nowhere/doesnotexist.js")
        } catch ELJSBridgeError.FileDoesNotExist {
            
        } catch _ {
            XCTFail("Expected loadFromFile to fail with error ELJSBridgeErrorFileDoesNotExist")
        }
    }
    
    func test_loadFromFile_successfullyLoadsValidJavaScriptFile() {
        let bridge = Bridge()
        let path = NSBundle(forClass: self.dynamicType).pathForResource("ELJSBridge_testdownload_good", ofType: "js")!
        
        do {
            try bridge.loadFromFile(path)
        } catch _ {
            XCTFail("Expected loadFromFile to run without throwing errors")
        }

        let result = bridge.contextValueForName("test").callWithArguments([2, 2])

        XCTAssertTrue(result.isNumber, "Expected the function to return a number type!")
        XCTAssertEqual(result.toInt32(), 4, "Expected the function to return a value of 4!")
    }

    func testPerformanceExampleJS() {
        let bridge = Bridge()
        let filename = "ELJSBridge_testdownload_good"
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource(filename, ofType: "js")
        do {
            try bridge.loadFromFile(path!)
        } catch {
            XCTFail("Error: \(error)")
        }
        
        let testFunction = bridge.context.objectForKeyedSubscript("test")
        let result = testFunction.callWithArguments([2, 2])

        XCTAssertTrue(result.isNumber, "the javascript function should've returned a number!")
        XCTAssertTrue(result.toInt32() == 4, "the javascript function should've returned a value of 4!")

        // start up our serial queue
        let serialQueue = dispatch_queue_create("blah", DISPATCH_QUEUE_SERIAL)

        self.measureBlock() {
            let expectation = self.expectationWithDescription("Loop execution completed.")
            // Put the code you want to measure the time of here.
            for index in 0..<1000 {
                dispatch_async(serialQueue, { () -> Void in
                    let result = testFunction.callWithArguments([1, index])
                    if index == 999 {
                        XCTAssertTrue(result.toInt32() == 1000)
                        expectation.fulfill()
                    }
                })
            }
            self.waitForExpectationsWithTimeout(5, handler: nil)
        }
        
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
