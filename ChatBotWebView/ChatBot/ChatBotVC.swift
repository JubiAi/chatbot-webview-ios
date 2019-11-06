//
//  ChatBotVC.swift
//  ChatBotWebView
//
//  Created by Ravi Rana on 27/06/19.
//  Copyright © 2019 Ravi Rana. All rights reserved.
//

import UIKit
import WebKit

let LaunchFlag = "launchFlag"
let KBaseUrlForChatBot = "https://esbot.jubi.ai/"
let kParametersForChatBot = "?query=getstarted&id=channel.ios-customerId.12345678-name.Jhon"

class ChatBotVC: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    var activityIndicator:UIActivityIndicatorView!
    
    
    override func loadView() {
        super.loadView()
        //initialise wkwebview
       
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Add script message handlers that, when run, will make the function
        // window.webkit.messageHandlers.test.postMessage() available in all frames.
        userContentController.add(self, name: "attachmentUrl")
        
        config.userContentController = userContentController
        
        // Inject JavaScript into the webpage. You can specify when your script will be injected and for
        // which frames–all frames or the main frame only.
        let scriptSource = "window.webkit.messageHandlers.attachmentUrl.postMessage(`Hello, world!`);"
        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        if message.name == "attachmentUrl" {
            print(message.body)
            if message.body is Dictionary<String, Any> {
            let dict = message.body as? Dictionary<String, Any>
            if let str = dict!["url"] as? String {
                let url = URL(string: str)!
                let pdfvc = PDFVC()
                pdfvc.fileUrl = url
                let navigation = UINavigationController.init(rootViewController: pdfvc)
                navigation.modalPresentationStyle = .overFullScreen
                present(navigation, animated: true, completion: nil)

            }
            }
        }
    }
    
    fileprivate func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView.init(style: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
    
     @objc func cancelAction() {
    dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add cancel button on navigation
        let cancelBtn = UIButton.init(frame: .zero)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        webView.addSubview(cancelBtn)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([cancelBtn.rightAnchor.constraint(equalTo: webView.rightAnchor, constant: -10),
            cancelBtn.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor, constant: 10),
            cancelBtn.widthAnchor.constraint(equalToConstant: 60),
            cancelBtn.heightAnchor.constraint(equalToConstant: 30)])
        
        
        //load url on webview
        var url: URL!
        if UserDefaults.standard.bool(forKey: LaunchFlag) != true {
        url = URL(string: KBaseUrlForChatBot+kParametersForChatBot)!
            UserDefaults.standard.set(true, forKey: LaunchFlag)
        }
        else {
            url = URL(string: KBaseUrlForChatBot)!
        }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        //add activityIndicator
        addActivityIndicator()
    }
    
    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        activityIndicator.stopAnimating()
    }
    
    
    
}

