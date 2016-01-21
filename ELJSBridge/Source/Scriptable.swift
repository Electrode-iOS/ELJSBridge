//
//  Scriptable.swift
//  ELJSBridge
//
//  Created by Brandon Sneed on 10/13/15.
//  Copyright © 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc
public protocol Scriptable {
    func reset()
    func inject(context: JSContext!)
}
