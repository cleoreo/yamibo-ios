//
//  ViewController.swift
//  yamibo-ios
//
//  Created by Cleo Chan on 2/6/2018.
//  Copyright © 2018 public. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController , WKUIDelegate, WKNavigationDelegate {

    var mainWebView: WKWebView!
    var refreshControl: UIRefreshControl!
    var progressView: UIProgressView!

    // spinner
    func showBlurLoader(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        blurEffectView.frame = CGRect( x: 0, y: statusBarHeight, width: view.bounds.maxX, height: view.bounds.maxY - statusBarHeight)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        
        self.view.addSubview(blurEffectView)
    }
    
    func removeBluerLoader(){
        self.view.subviews.flatMap {  $0 as? UIVisualEffectView }.forEach {
            $0.removeFromSuperview()
        }
    }
    
    // webview
    private func setupWebView() {
        let contentController = WKUserContentController()
        
        // add jquery
        guard let jqueryPath = Bundle.main.path(forResource: "jquery-3.3.1.min", ofType: "js", inDirectory: "js"),
            let jquerySource = try? String(contentsOfFile: jqueryPath) else { return }
        
        let jquery = WKUserScript(source: jquerySource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(jquery)
        
        // add photo swipe
        guard let photoSwipeScriptPath = Bundle.main.path(forResource: "photoswipe.min", ofType: "js", inDirectory: "js"),
            let photoSwipeScriptSource = try? String(contentsOfFile: photoSwipeScriptPath) else { return }

        let photoSwipe = WKUserScript(source: photoSwipeScriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(photoSwipe)

        guard let photoSwipeUIScriptPath = Bundle.main.path(forResource: "photoswipe-ui-default.min", ofType: "js", inDirectory: "js"),
            let photoSwipeUIScriptSource = try? String(contentsOfFile: photoSwipeUIScriptPath) else { return }

        let photoSwipeUI = WKUserScript(source: photoSwipeUIScriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(photoSwipeUI)

        // add font awesome script
        guard let fontAwesomeScriptPath = Bundle.main.path(forResource: "fontawesome-all.min", ofType: "js", inDirectory: "js"),
            let fontAwesomeScriptSource = try? String(contentsOfFile: fontAwesomeScriptPath) else { return }
        
        let fontAwesome = WKUserScript(source: fontAwesomeScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(fontAwesome)
        
        // add translation script
        guard let translationScriptPath = Bundle.main.path(forResource: "jquery.s2t.min", ofType: "js", inDirectory: "js"),
            let translationScriptSource = try? String(contentsOfFile: translationScriptPath) else { return }
        
        let translation = WKUserScript(source: translationScriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(translation)
        
        // add desktop script
        guard let desktopScriptPath = Bundle.main.path(forResource: "desktop", ofType: "js", inDirectory: "js"),
            let desktopScriptSource = try? String(contentsOfFile: desktopScriptPath) else { return }

        let desktop = WKUserScript(source: desktopScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(desktop)

        // add mobile script
        guard let mobileScriptPath = Bundle.main.path(forResource: "main", ofType: "js", inDirectory: "js"),
            let mobileScriptSource = try? String(contentsOfFile: mobileScriptPath) else { return }
        
        let mobile = WKUserScript(source: mobileScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(mobile)
    
        
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        mainWebView = WKWebView( frame: CGRect( x: 0, y: statusBarHeight, width: view.bounds.maxX, height: view.bounds.maxY - statusBarHeight), configuration: config)
       
       
        // webview setting
        mainWebView.allowsBackForwardNavigationGestures = true
        mainWebView.scrollView.isScrollEnabled = true
        mainWebView.scrollView.alwaysBounceVertical = true
        mainWebView.scrollView.bounces  = true
        
        mainWebView.uiDelegate = self
        mainWebView.navigationDelegate = self
        mainWebView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        mainWebView.scrollView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
        mainWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
        
        // add progress bar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        progressView.tintColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        progressView.frame = CGRect( x: 0, y: statusBarHeight - 2, width: view.bounds.maxX, height: 2)
        self.view.addSubview(progressView)
        
        self.mainWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        
        self.view.addSubview(self.mainWebView)
        
}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set background color webview
        self.view.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)

        self.setupWebView()
        
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        mainWebView.scrollView.addSubview(refreshControl)
        
        let url = URL(string: "https://bbs.yamibo.com/forum.php?mobile=1")
        let request = URLRequest(url: url!)
        
        mainWebView.load(request)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didPullToRefresh() {
        mainWebView.reload()
        refreshControl?.endRefreshing()
    }
    
    // display alert handler
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "OK Button")
        let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true)
        completionHandler()
        
    }
    // display and copy text from prompt handler
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        UIPasteboard.general.string = defaultText
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(defaultText)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    // url handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix("bbs.yamibo.com"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
//                print(url)
//                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
//                print(navigationAction.request.url)
//                print("Open it locally")
                let url = navigationAction.request.url
                let request = URLRequest(url: url!)
                mainWebView.load(request)
                decisionHandler(.allow)
            }
        } else {
//            print("not a user click")
            decisionHandler(.allow)
        }
    }
    // add progress bar
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else { return }
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.progress = progress;
                if progress > 0.6 {
                    self.removeBluerLoader()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        self.removeBluerLoader()
//                    }
                }
            }
            return
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        self.showBlurLoader()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//             self.showBlurLoader()
//        }
       
    }

}

