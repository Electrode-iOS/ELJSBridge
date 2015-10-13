//
//  Scriptable.swift
//  THGBridge
//
//  Created by Brandon Sneed on 10/13/15.
//  Copyright © 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc
public protocol Scriptable {
    func reset()
    func inject(context: JSContext!)
}