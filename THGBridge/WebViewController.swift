//
//  WebViewController.swift
//  THGBridge
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

public class WebViewController: UIViewController {
    
    var webView: UIWebView? {
        didSet {
            webView?.delegate = self
        }
    }
    
    private(set) public var url: NSURL?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        webView = UIWebView(frame: self.view.frame)
        webView?.delegate = self
        view.addSubview(webView!)

    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if webView?.delegate === self {
            self.webView?.delegate = nil
        }
    }
}

// MARK: - UIViewController

extension WebViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Request Loading

extension WebViewController {
    
    public func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        self.webView?.loadRequest(request)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("WebViewController Error: \(error)")
    }
}
