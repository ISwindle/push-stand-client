//
//  PrivacyPolicyViewController.swift
//  Push Stand
//
//  Created by Isaac Swindle on 3/23/24.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadPrivacyPolicy()
    }
    
    private func setupWebView() {
        webView.allowsBackForwardNavigationGestures = true
    }
    
    private func loadPrivacyPolicy() {
        guard let url = URL(string: "https://pushstand.com/privacy.html") else {
            showErrorAlert()
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Unable to load Privacy Policy.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started loading")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished loading")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load: \(error.localizedDescription)")
        showErrorAlert()
    }
}
