//
//  WebViewControllerScript.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/28/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

protocol WebViewControllerType: class {}

@objc public class WebViewControllerScript: NSObject {
    weak var parentViewController: UIViewController?

    init(parentViewController: WebViewControllerType) {
        self.parentViewController = parentViewController as? UIViewController
    }
}
