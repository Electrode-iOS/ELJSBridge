//
//  WebViewController.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

public class WebViewController: UIViewController {
    
    private(set) public var url: NSURL?
    private var shouldAnimateHistoryChange = true
    private var hasAppeared = false
    private var showWebViewOnAppear = false
    private(set) public var webView = UIWebView(frame: CGRectZero)
    public var bridge = Bridge()

    private lazy var placeholderImageView: UIImageView = {
        return UIImageView(frame: self.view.bounds)
    }()
    
    var isAppearingFromPop: Bool {
        return !isMovingFromParentViewController() && webView.superview != view
    }
    
    convenience init(webView: UIWebView, bridge: Bridge) {
        self.init(nibName: nil, bundle: nil)
        self.bridge = bridge
        self.webView = webView
        self.webView.delegate = self
    }
    
    deinit {
        if webView.delegate === self {
            webView.delegate = nil
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        edgesForExtendedLayout = .None
        view.addSubview(placeholderImageView)
        containWebView()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        bridge.platform?.navigation?.webNavigator = self
        
        if isAppearingFromPop {
            popState()
            containWebView()
        }
        
        if !webView.loading {
            showWebViewOnAppear = true
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        hasAppeared = true
        
        if showWebViewOnAppear {
            webView.hidden = false
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        placeholderImageView.frame = webView.frame // must align frames for image capture
        placeholderImageView.image = webView.captureImage()
        webView.hidden = true
    }
    
    func containWebView() {
        webView.delegate = self
        webView.removeFromSuperview()
        webView.frame = view.bounds
        view.addSubview(webView)
    }
    
    func attemptToShowWebView() {
        if hasAppeared {
            webView.hidden = false
        } else {
            // wait for viewDidAppear to show web view
            showWebViewOnAppear = true
        }
    }
}

// MARK: - Request Loading

extension WebViewController {
    
    public func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        self.webView.loadRequest(request)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {

        if !webView.loading {
            updateBridgeContext() // todo: listen for context changes
            attemptToShowWebView()
        }
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        var shouldStartLoad = true
        
        switch navigationType {
        case .LinkClicked:
            pushWebViewController(animated: shouldAnimateHistoryChange)
        default:
            break
        }
        
        return shouldStartLoad
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("WebViewController Error: \(error)")
    }
    
    public func updateBridgeContext() {
        if let context =  webView.javaScriptContext {
            configureBridgeContext(context)
        } else {
            println("Failed to retrieve JavaScript context from web view.")
        }
    }
    
    public func configureBridgeContext(context: JSContext) {
        bridge.context = context
        bridge.addPlatformIfNeeded()
        bridge.platform?.navigation?.webNavigator = self
    }
}

// MARK: - WebViewControllerNavigator

@objc protocol WebViewControllerNavigator {
    func pushState()
    func popState()
    func replaceState()
}

// MARK: - Web Navigation

extension WebViewController: WebViewControllerNavigator {
    
    func popState() {
        webView.goBack()
    }
    
    func pushState() {
        pushWebViewController(animated: shouldAnimateHistoryChange)
    }
    
    func replaceState() {
        
    }
    
    func pushWebViewController(#animated: Bool) {
        let webViewController = WebViewController(webView: webView, bridge: bridge)
        navigationController?.pushViewController(webViewController, animated: animated)
    }
}

// MARK: - Bridge Platform API

extension WebViewController {

    func configureBridgePlatform() {
        bridge.platform?.navigation?.webNavigator = self
    }
}

// MARK: - UIView Utils

extension UIView {
    
    func captureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

private let webViewJavaScriptContextPath = "documentView.webView.mainFrame.javaScriptContext"

// MARK: - UIWebView's JavaScriptContext

extension UIWebView {
    /**
    Retreive the JavaScript context from the web view.
    */
    var javaScriptContext: JSContext? {
        return valueForKeyPath(webViewJavaScriptContextPath) as? JSContext
    }
}

