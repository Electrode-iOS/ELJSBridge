//
//  WebViewController.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation


public class WebViewController: UIViewController {
    
    private(set) public var url: NSURL?
    private var shouldAnimateHistoryChange = true
    private var hasAppeared = false
    private var showWebViewOnAppear = false
    private(set) public var webView = UIWebView(frame: CGRectZero)

    private lazy var placeholderImageView: UIImageView = {
        return UIImageView(frame: self.view.bounds)
    }()
    
    var isAppearingFromPop: Bool {
        return !isMovingFromParentViewController() && webView.superview != view
    }
    
    convenience init(webView: UIWebView) {
        self.init(nibName: nil, bundle: nil)
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
        
        if isAppearingFromPop {
            popState()
            containWebView()
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
            attemptToShowWebView()
        }
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var shouldStartLoad = true
        
        switch navigationType {
        case .LinkClicked:
            animatePushState()
        default:
            break
        }
        
        return shouldStartLoad
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
//        println("WebViewController Error: \(error)")
    }
}

// MARK: - UIWebView History

extension WebViewController {
    
    func popState() {
        webView.goBack()
    }
    
    func onPushState() {
        if shouldAnimateHistoryChange {
            animatePushState()
        }
    }
    
    func onPopState() {
        
    }
    
    func animatePushState() {
        let webViewController = WebViewController(webView: webView)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}


// MARK: - Utils

extension UIView {
    
    func captureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
