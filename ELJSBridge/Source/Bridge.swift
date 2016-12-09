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

public enum ELJSBridgeError: Error {
    case fileDoesNotExist
    case fileCouldNotBeLoaded
    case failedToDownloadScript
    case failedToEvaluateScript
}

@objc(ELJSBridge)
open class Bridge: NSObject {

    /// The JS context in which this bridge operates.
    open var context: JSContext {
        didSet {
            for (name, script) in exports {
                context.setObject(script, forKeyedSubscript: name as NSString!)
            }
            
            context.exceptionHandler = { context, exception in
                log(.Debug, "JSError = \(exception)")
            }
        }
    }

    fileprivate(set) open var exports = [String: JSExport]()

    public override init() {
        context = JSContext(virtualMachine: JSVirtualMachine())
    }

    /**
     Load JS from a file at the given path.
     
     - parameter filePath: Path to the JS file.
     */
    open func loadFromFile(_ filePath: String) throws {
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw ELJSBridgeError.fileDoesNotExist
        }
        guard let script = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8) else {
            throw ELJSBridgeError.fileCouldNotBeLoaded
        }
        
        try load(script)
    }

    /**
     Load JS from a resource at the given URL.
     
     - parameter downloadURL: URL to the JS resource.
     - parameter completion: The completion block to call after the resource is loaded into the bridge.
     */
    open func loadFromURL(_ downloadURL: URL, completion: @escaping (_ error: Error?) -> Void) {
        downloadScript(downloadURL) { (data, error) -> Void in
            if let error = error {
                completion(error)
            } else {
                if let data = data, let script = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                    do {
                        try self.load(script)
                        completion(nil)
                    } catch let catchError as NSError {
                        completion(catchError)
                    } catch {
                        completion(ELJSBridgeError.failedToDownloadScript)
                    }
                } else {
                    completion(ELJSBridgeError.failedToDownloadScript)
                }
            }
        }
    }

    /**
     Load JS from a String.
     
     - parameter script: The JS to load.
     */
    open func load(_ script: String) throws {
        context.evaluateScript(script)
        if let exception = context.exception {
            log(.Debug, "Load failed with exception: \(exception)")
            throw ELJSBridgeError.failedToEvaluateScript
        }
    }

    fileprivate func downloadScript(_ url: URL, completion: @escaping (_ data: Data?, _ error: Error?) -> Void)
    {
        let downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 404 {
                completion(nil, ELJSBridgeError.fileDoesNotExist)
            } else {
                completion(data, error)
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
    public func addExport(_ export: JSExport, name: String) {
        exports[name] = export
        context.setObject(export, forKeyedSubscript: name as NSString!)
    }
    
    /**
     Retrieve a JSValue out of the context by name.
     - parameter name: Name of value to retrieve out of context.
    */
    public func contextValueForName(_ name: String) -> JSValue {
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
    public func injectRuntime(_ runtime: Scriptable) {
        runtime.reset()
        runtime.inject(context)
    }
    
}
