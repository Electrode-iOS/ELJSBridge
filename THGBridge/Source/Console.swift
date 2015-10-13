//
//  Console.swift
//  THGBridge
//
//  Created by Brandon Sneed on 10/13/15.
//  Copyright © 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc
public enum ConsoleOutputType: Int {
    case Log = 0
    case Info = 1
    case Error = 2
    case Warning = 3
    case Assert = 4
    case Timestamp = 5
}

@objc
public protocol ConsoleSupportable: JSExport {
    func output(type: ConsoleOutputType, arguments: [AnyObject])
}

public typealias OutputHandler = ((type: ConsoleOutputType, message: String) -> Void)

@objc
public class Console: NSObject, ConsoleSupportable, Scriptable {
    
    public func output(type: ConsoleOutputType, arguments: [AnyObject]) {
        var output: String = ""
        
        switch type {
        case .Error: output += "⛔️"
        case .Warning: output += "⚠️"
            
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
            handler(type: type, message: output)
        }
    }
    
    public func reset() {
        //
    }
    
    public func inject(context: JSContext!) {
        if context == nil {
            return
        }
        
        context.setObject(self, forKeyedSubscript: "$console")
        
        context.evaluateScript(
            "console = {\n" +
                "log: function () { $console.outputArguments(0, arguments); },\n" +
                "warn: function () { $console.outputArguments(3, arguments); },\n" +
                "error: function () { $console.outputArguments(2, arguments); }\n" +
            "};\n"
        )
    }
    
    // allows for a custom output handler to be specified.
    public var outputHandler: OutputHandler? = nil

}