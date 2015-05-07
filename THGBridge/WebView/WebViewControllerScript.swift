//
//  WebViewControllerScript.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/28/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

public protocol WebViewControllerType: class {}

@objc public class WebViewControllerScript: NSObject {
    public weak var parentViewController: UIViewController?

    public init(parentViewController: WebViewControllerType) {
        self.parentViewController = parentViewController as? UIViewController
    }
}
