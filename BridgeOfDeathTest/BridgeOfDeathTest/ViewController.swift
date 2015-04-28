//
//  ViewController.swift
//  BridgeOfDeathTest
//
//  Created by Angelo Di Paolo on 4/21/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import THGBridge

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openWebView(sender: UIButton) {
        let webController = WebViewController.WithBridgePlatform()
        let navController = UINavigationController(rootViewController: webController)
        let url = NSURL(string: "https://dl.dropboxusercontent.com/u/6589453/wm/bridge/bridge-test.html")!
//        let url = NSURL(string: "http://bridgeofdeath.herokuapp.com/")!

        webController.loadURL(url)
        presentViewController(navController, animated: true, completion: nil)
    }
}
