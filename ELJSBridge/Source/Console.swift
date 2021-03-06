//
//  Console.swift
//  ELJSBridge
//
//  Created by Brandon Sneed on 10/13/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc
public enum ConsoleOutputType: Int {
    case log = 0
    case info = 1
    case error = 2
    case warning = 3
    case assert = 4
    case timestamp = 5
}

@objc
public protocol ConsoleSupportable: JSExport {
    /**
     Output to the console.
     
     - parameter type: The type of output.
     - parameter arguments: The objects to be outputted by converting into strings.
     */
    func output(_ type: ConsoleOutputType, arguments: [AnyObject])
}

public typealias OutputHandler = ((_ type: ConsoleOutputType, _ message: String) -> Void)

/**
 This class implements console functions commonly expected in the JS runtime like in a browser but are not present by default in the Bridge.
 For list of functions, see `ConsoleSupportable`.
 */
@objc
open class Console: NSObject, ConsoleSupportable, Scriptable {
    
    open func output(_ type: ConsoleOutputType, arguments: [AnyObject]) {
        var output: String = ""
        
        switch type {
        case .error: output += "⛔️"
        case .warning: output += "⚠️"
            
        default:
            break
        }
        
        for i in 0..<arguments.count {
            if let stringValue = arguments[i] as? String {
                output += stringValue
            } else if let jsValue = arguments[i] as? JSValue {
                output += jsValue.toString()
            } else if let dictValue = arguments[i] as? NSDictionary {
                output += String(format: "%@", dictValue)
            }
            
            if i != arguments.count - 1 {
                output += " "
            }
        }
        
        if let handler = outputHandler {
            handler(type, output)
        } else {
            print(output)
        }
    }
    
    open func reset() {
        //
    }
    
    open func inject(_ context: JSContext!) {
        if context == nil {
            return
        }
        
        context.setObject(self, forKeyedSubscript: "$console" as NSString!)
        
        context.evaluateScript(
            "console = {\n" +
                "log: function () { $console.outputArguments(0, arguments); },\n" +
                "warn: function () { $console.outputArguments(3, arguments); },\n" +
                "error: function () { $console.outputArguments(2, arguments); }\n" +
            "};\n"
        )
    }
    
    // allows for a custom output handler to be specified.
    open var outputHandler: OutputHandler? = nil

}
