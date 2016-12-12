//
//  Scriptable.swift
//  ELJSBridge
//
//  Created by Brandon Sneed on 10/13/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore

/**
Implement this protocol to allow a custom object to be injected or removed from the `JSContext` passed in.
*/
@objc
public protocol Scriptable {
    /**
     An opportunity to reset state. Called before `inject`.
     */
    func reset()
    
    /**
     Inject the methods defined by an object into the passed in `JSContext`.
     
     - parameter context: The `JSContext` being modified.
     */
    func inject(_ context: JSContext!)
}
