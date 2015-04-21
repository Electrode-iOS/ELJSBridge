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
    var shouldAnimateHistoryChange = true
    var isSharingWebView = false
    
    lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(frame: self.view.bounds)
        self.view.insertSubview(imageView, atIndex: 0)
        return imageView
    }()
    
    private(set) public lazy var webView: UIWebView = {
        let webView = UIWebView(frame: self.view.bounds)
        webView.delegate = self
        self.view.addSubview(webView)
        return webView
    }()
    
    var isAppearingFromPop: Bool {
        return !isMovingFromParentViewController() && webView.superview != view
    }
    
    convenience init(webView: UIWebView) {
        self.init(nibName: nil, bundle: nil)
        self.webView = webView
        self.isSharingWebView = true
    }
    
    deinit {
        if webView.delegate === self {
            webView.delegate = nil
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if isSharingWebView {
            containWebView()
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAppearingFromPop {
            popState()
            containWebView()
        }
    }
    
    func containWebView() {
        webView.delegate = self
        webView.removeFromSuperview()
        webView.frame = view.bounds
        webView.scrollView.contentInset = UIEdgeInsetsZero
        webView.hidden = false // todo: wait to unhide untill load completes
        view.addSubview(webView)
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
        println("WebViewController Error: \(error)")
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
        placeholderImageView.image = view.captureImage()
        webView.hidden = true
        
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
