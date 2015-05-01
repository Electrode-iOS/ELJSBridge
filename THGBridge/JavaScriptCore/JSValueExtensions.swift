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
     Calls the value like it was a JavaScript function in the form of 
     `function(error, data)`.
     :param: data The data that is passed to the callback
     :return: The return value of the function call.
    */
    func callWithData(data: AnyObject) -> JSValue! {
        return callWithArguments([NSNull(), data])
    }
    
    /**
     Calls the value like it was a JavaScript function in the form of
     `function(error, data)`.
     :param: error The error that is passed to the callback.
     :return: The return value of the function call.
    */
    func callWithError(error: NSError) -> JSValue! {
        return callWithErrorMessage(error.localizedDescription)
    }
    
    /**
    Calls the value like it was a JavaScript function in the form of
    `function(error, data)`.
    :param: errorMessage The message used to create the JavaScript error
     that is passed to the callback.
    :return: The return value of the function call.
    */
    func callWithErrorMessage(errorMessage: String) -> JSValue! {
        let jsError = JSValue(newErrorFromMessage: errorMessage, inContext: context)
        return callWithArguments([jsError, NSNull()])
    }
}
