//
//  Bridge.swift
//  ELJSBridge
//
//  Created by Brandon Sneed on 3/25/15.
//  Copyright (c) WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore
#if NOFRAMEWORKS
#else
    #if os(OSX)
        import ELFoundation_osx
        import ELLog_osx
    #elseif os(iOS)
        import ELFoundation
        import ELLog
    #endif
#endif

public enum ELJSBridgeError: Int, NSErrorEnum {
    case FileDoesNotExist
    case FailedToDownloadScript
    case FailedToEvaluateScript

    public var domain: String {
        return "com.walmartlabs.ELJSBridgeError"
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

@objc(ELJSBridge)
public class Bridge: NSObject {

    public var context: JSContext {
        didSet {
            for (name, script) in exports {
                
                print("add \(name) \(script)")
                
                context.setObject(script, forKeyedSubscript: name)
            }
            
            context.exceptionHandler = { context, exception in
                log(.Debug, "JSError = \(exception)")
            }
        }
    }

    private(set) public var exports = [String: JSExport]()

    public override init() {
        context = JSContext(virtualMachine: JSVirtualMachine())
    }

    public func loadFromFile(filePath: String) throws {
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(filePath) {
            do {
                let script = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
                do {
                    try self.load(script)
                } catch let catchError as NSError {
                    throw catchError
                }
            } catch  {
                throw NSError(ELJSBridgeError.FileDoesNotExist)
            }
        }
        
    }

    public func loadFromURL(downloadURL: NSURL, completion: (error: NSError?) -> Void) {
        downloadScript(downloadURL) { (data, error) -> Void in
            if let error = error {
                completion(error: error)
            } else {
                if let data = data, let script = NSString(data: data, encoding: NSUTF8StringEncoding) as String? {
                    do {
                        try self.load(script)
                        completion(error: nil)
                    } catch let catchError as NSError {
                        completion(error: catchError)
                    } catch {
                        completion(error: NSError(ELJSBridgeError.FailedToDownloadScript))
                    }
                } else {
                    completion(error: NSError(ELJSBridgeError.FailedToDownloadScript))
                }
            }
        }
    }

    public func load(script: String) throws {
        context.evaluateScript(script)
        if let exception = context.exception {
            print("Load failed with exception: \(exception)")
            throw NSError(ELJSBridgeError.FailedToEvaluateScript)
        }
    }

    private func downloadScript(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void)
    {
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            let httpResponse = response as? NSHTTPURLResponse
            if httpResponse?.statusCode == 404 {
                completion(data: nil, error: NSError(ELJSBridgeError.FileDoesNotExist))
            } else {
                completion(data: data, error: error)
            }
        }
        
            downloadTask.resume()
    }
}

// MARK: - Exports API

public extension Bridge {
    /**
    Add an exported object to the context
    :param: export Object being exported to JavaScript
    :param: name Name of object being exported
    */
    public func addExport(export: JSExport, name: String) {
        exports[name] = export
        context.setObject(export, forKeyedSubscript: name)
    }
    
    /**
    Retrieve a JSValue out of the context by name.
    :param: name Name of value to retrieve out of context.
    */
    public func contextValueForName(name: String) -> JSValue {
        return context.objectForKeyedSubscript(name)
    }
}

// MARK: - Global Runtime API

public extension Bridge {
    
    /**
    Injects a global runtime that defines native implementations of commonly needed JS functions.
    Defines: setTimeout, clearTimeout, setInterval, clearInterval
    Redefines: console.log, warn, error, 
    */
    public func injectRuntime(runtime: Scriptable) {
        runtime.reset()
        runtime.inject(context)
    }
    
}
