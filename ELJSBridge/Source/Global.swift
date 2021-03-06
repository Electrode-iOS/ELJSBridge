//
//  Global.swift
//  ELJSBridge
//
//  Created by Sam Grover on 9/30/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc
public protocol GlobalSupportable: JSExport {
    /**
     Calls a function after some milliseconds.
     
     - parameter fn: The function to call
     - parameter timeout: The time, in milliseconds, after which to call function.
     - returns: An identifier that can be used to cancel the call back using `clearTimeout`.
     */
    func set(_ fn: JSValue, timeout: JSValue) -> UInt
    
    /**
     Cancel a function scheduled to be called with `setTimeout`.
     
     - parameter identifier: The identifier returned by `setTimeout`.
     */
    func clearTimeout(_ identifier: UInt)
   
    /**
     Calls a function after a regular interval of some milliseconds until cleared.
     
     - parameter fn: The function to call
     - parameter interval: The interval, in milliseconds, after which to call function.
     - returns: An identifier that can be used to cancel the call back.
     */
    func set(_ fn: JSValue, interval: JSValue) -> UInt
    
    /**
     Cancel a function scheduled to be called regularly with `setInterval`.
     
     - parameter identifier: The identifier returned by `setInterval`.
     */
    func clearInterval(_ identifier: UInt)
}

/**
 This class implements functions commonly expected in the JS runtime like in a browser but are not present by default in the Bridge.
 For list of functions, see `GlobalSupportable`.
*/
@objc
open class Global: NSObject, GlobalSupportable, Scriptable {
    
    // Stores all functions set up with setTimeout and setInterval along with their parameters. Removed after dispatch (in case of setTimeout) or when cleared.
    // Keeping all input values as JSValues so that they can be called on the JS function,  'fn',  in the dispatch and sent back as they came.
    var jsFunctions = [UInt: [JSValue]]()
    
    open func set(_ fn: JSValue, timeout: JSValue) -> UInt {
        let identifier = UInt(arc4random())
        jsFunctions[identifier] = [fn, timeout]
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeout.toInt32()) * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) { () -> Void in
            if let _ = self.jsFunctions[identifier] {
                fn.call(withArguments: [timeout])
                self.jsFunctions.removeValue(forKey: identifier)
            }
        }
        
        return identifier
    }
    
    open func clearTimeout(_ identifier: UInt) {
        removeJSFunction(identifier)
    }
    
    open func set(_ fn: JSValue, interval: JSValue) -> UInt {
        let identifier = UInt(arc4random())
        let values = [fn, interval]
        jsFunctions[identifier] = values
        setupIntervalDispatch(identifier, interval: interval)
        return identifier
    }
    
    open func clearInterval(_ identifier: UInt) {
        removeJSFunction(identifier)
    }
    
    open func reset() {
        //
    }
    
    open func inject(_ context: JSContext!) {
        if context == nil {
            return
        }
        
        context.setObject(self, forKeyedSubscript: "$global" as NSString!)
        
        // This has been broken up into succcesive statements because chaining the '+' operator significantly increases compile
        // time in Swift at this time.
        var script = "global = {\n"
        script = script + "setTimeout: function (fn, timeout) { return $global.setTimeout(fn, timeout); },\n"
        script = script + "clearTimeout: function (identifier) { $global.clearTimeout(identifier); },\n"
        script = script + "setInterval: function (fn, interval) { return $global.setInterval(fn, interval); },\n"
        script = script + "clearInterval: function (identifier) { $global.clearInterval(identifier); },\n"
        script = script + "};\n"
        script = script + "setTimeout = global.setTimeout\n"
        script = script + "clearTimeout = global.clearTimeout\n"
        script = script + "setInterval = global.setInterval\n"
        script = script + "clearInterval = global.clearInterval\n"
        
        context.evaluateScript(script)

    }
    
    internal func setupIntervalDispatch(_ identifier: UInt, interval: JSValue) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(interval.toInt32()) * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) { () -> Void in
            // If there are no values associated any longer (due to a clearInterval call), then it will not set up another dispatch and the recursion will end.
            if let values = self.jsFunctions[identifier] {
                let fn = values[0]
                fn.call(withArguments: [interval])
                // Call this function recursively to set up the next dispatch
                self.setupIntervalDispatch(identifier, interval: interval)
            }
        }
    }
    
    internal func removeJSFunction(_ identifier: UInt) {
        self.jsFunctions.removeValue(forKey: identifier)
    }
    
    internal let consoleLog: () -> Void = {
        let args = JSContext.currentArguments()
        
        print(args ?? "No Args Passed")
    }
}
