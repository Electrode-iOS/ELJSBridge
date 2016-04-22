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
        import ELFoundation
        import ELLog
    #elseif os(iOS)
        import ELFoundation
        import ELLog
    #endif
#endif

public enum ELJSBridgeError: ErrorType {
    case FileDoesNotExist
    case FileCouldNotBeLoaded
    case FailedToDownloadScript
    case FailedToEvaluateScript
}

@objc(ELJSBridge)
public class Bridge: NSObject {

    /// The JS context in which this bridge operates.
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

    public override init() {
        context = JSContext(virtualMachine: JSVirtualMachine())
    }

    /**
     Load JS from a file at the given path.
     
     - parameter filePath: Path to the JS file.
     */
    public func loadFromFile(filePath: String) throws {
        guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else {
            throw ELJSBridgeError.FileDoesNotExist
        }
        guard let script = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) else {
            throw ELJSBridgeError.FileCouldNotBeLoaded
        }
        
        try load(script)
    }

    /**
     Load JS from a resource at the given URL.
     
     - parameter downloadURL: URL to the JS resource.
     - parameter completion: The completion block to call after the resource is loaded into the bridge.
     */
    public func loadFromURL(downloadURL: NSURL, completion: (error: ErrorType?) -> Void) {
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
                        completion(error: ELJSBridgeError.FailedToDownloadScript)
                    }
                } else {
                    completion(error: ELJSBridgeError.FailedToDownloadScript)
                }
            }
        }
    }

    /**
     Load JS from a String.
     
     - parameter script: The JS to load.
     */
    public func load(script: String) throws {
        context.evaluateScript(script)
        if let exception = context.exception {
            log(.Debug, "Load failed with exception: \(exception)")
            throw ELJSBridgeError.FailedToEvaluateScript
        }
    }

    private func downloadScript(url: NSURL, completion: (data: NSData?, error: ErrorType?) -> Void)
    {
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            let httpResponse = response as? NSHTTPURLResponse
            if httpResponse?.statusCode == 404 {
                completion(data: nil, error: ELJSBridgeError.FileDoesNotExist)
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
     - parameter export: Object being exported to JavaScript
     - parameter name: Name of object being exported
    */
    public func addExport(export: JSExport, name: String) {
        exports[name] = export
        context.setObject(export, forKeyedSubscript: name)
    }
    
    /**
     Retrieve a JSValue out of the context by name.
     - parameter name: Name of value to retrieve out of context.
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
