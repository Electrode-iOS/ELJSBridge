//
//  Bridge.swift
//  THGBridge
//
//  Created by Brandon Sneed on 3/25/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore
import THGFoundation
import THGLog

public enum THGBridgeError: Int, NSErrorEnum {
    case FileDoesNotExist
    case FailedToDownloadScript
    case FailedToEvaluateScript

    public var domain: String {
        return "io.theholygrail.THGBridgeError"
    }

    public var errorDescription: String {
        switch self {
        case .FileDoesNotExist:
            return "File does not exist."
        case .FailedToDownloadScript:
            return "Failed to download script."
        case .FailedToEvaluateScript:
            return "Failed to evaluate script."
        }
    }
}

@objc(THGBridge)
public class Bridge {

    public var context: JSContext {
        didSet {
            for (name, script) in exports {
                context.setObject(script, forKeyedSubscript: name)
            }
            
            context.exceptionHandler = { context, exception in
                log(.Debug, "JSError = \(exception)")
            }
        }
    }

    private(set) public var exports = [String: JSExport]()

    public init() {
        context = JSContext(virtualMachine: JSVirtualMachine())
    }

    public func loadFromFile(filePath: String, error: NSErrorPointer = nil) {
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(filePath) {
            if let script = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: error) {
                var loadError: NSError? = nil
                self.load(script, error: &loadError)
                if let loadError = loadError {
                    error.memory = loadError
                }
            }
        } else {
            if (error != nil) {
                error.memory = NSError(THGBridgeError.FileDoesNotExist)
            }
        }
    }

    public func loadFromURL(downloadURL: NSURL, completion: (error: NSError?) -> Void) {
        downloadScript(downloadURL) { (data, error) -> Void in
            if let error = error {
                completion(error: error)
            } else {
                if let data = data, let script = NSString(data: data, encoding: NSUTF8StringEncoding) as String? {
                    var error: NSError? = nil
                    self.load(script, error: &error)
                    completion(error: error)
                } else {
                    completion(error: NSError(THGBridgeError.FailedToDownloadScript))
                }
            }
        }
    }

    public func load(script: String, error: NSErrorPointer = nil) {
        let value = context.evaluateScript(script)
        /*if value.isUndefined() {
            let anError = NSError(THGBridgeError.FailedToEvaluateScript)
            error.memory = anError
        }*/
    }

    private func downloadScript(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void)
    {
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            let httpResponse = response as? NSHTTPURLResponse
            if httpResponse?.statusCode == 404 {
                completion(data: nil, error: NSError(THGBridgeError.FileDoesNotExist))
            } else {
                completion(data: data, error: error)
            }
        }

        downloadTask.resume()
    }

    // MARK: Exports API
    
    public func addExport(export: JSExport, name: String) {
        exports[name] = export
        context.setObject(export, forKeyedSubscript: name)
    }
    
    public func contextValueForName(name: String) -> JSValue {
        return context.objectForKeyedSubscript(name)
    }
}

