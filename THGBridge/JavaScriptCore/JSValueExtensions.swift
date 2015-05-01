//
//  JSValueExtensions.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 5/1/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

internal extension JSValue {
    
    /**
     Call the JavaScript function value with data and error params. The bridge 
     API uses a popular convention for JavaScript callbacks: `function(error, data)`.
     This method is convenience for invoking a callback that follows this convention.
    */
    func callWithWithData(data: AnyObject, error: NSError?) -> JSValue! {
        let args: [AnyObject]
        
        if let error = error {
            args = [error, data]
        } else {
            args = [NSNull(), data]
        }
        
        return callWithArguments(args)
    }
}
