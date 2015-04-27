//
//  WebViewController.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc class WebViewControllerScript: NSObject {
    weak var parentWebViewController: WebViewController?
}

public class WebViewController: UIViewController {
    
    private(set) public var url: NSURL?
    private(set) public var webView = UIWebView(frame: CGRectZero)
    private(set) public var bridge = Bridge()
    private var hasAppeared = false
    private var showWebViewOnAppear = false

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
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        bridge.platform?.parentWebViewController = self
        
        if isAppearingFromPop {
            webView.goBack() // go back before remove/adding web view
        }
        
        webView.delegate = self
        webView.removeFromSuperview()
        webView.frame = view.bounds
        view.addSubview(webView)
        
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
        
        func attemptToShowWebView() {
            if hasAppeared {
                self.webView.hidden = false
            } else {
                // wait for viewDidAppear to show web view
                showWebViewOnAppear = true
            }
        }

        if !webView.loading {
            updateBridgeContext() // todo: listen for context changes
            attemptToShowWebView()
        }
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if pushesWebViewControllerForNavigationType(navigationType) {
            pushWebViewController()
        }
        
        return true
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("WebViewController Error: \(error)")
    }
}

// MARK: - JavaScript Context

extension WebViewController {
    
    public func updateBridgeContext() {
        if let context = webView.javaScriptContext {
            configureBridgeContext(context)
        } else {
            println("Failed to retrieve JavaScript context from web view.")
        }
    }
    
    public func configureBridgeContext(context: JSContext) {
        bridge.context = context
        bridge.context.evaluateScript("window.nativeBridgeReady();")
    }
}

// MARK: - Web Controller Navigation

extension WebViewController {

    func pushWebViewController() {
        let webViewController = WebViewController(webView: webView, bridge: bridge)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func popWebViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func pushesWebViewControllerForNavigationType(navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        default:
            return false
        }
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
