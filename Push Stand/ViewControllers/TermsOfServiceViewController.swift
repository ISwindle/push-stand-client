//
//  TermsOfServiceViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 3/23/24.
//

import UIKit
import WebKit

class TermsOfServiceViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: Constants.URL.termsOfService)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
}

