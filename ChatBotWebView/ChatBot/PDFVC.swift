//
//  PDFVC.swift
//  ChatBotWebView
//
//  Created by Ravindra on 16/07/19.
//  Copyright © 2019 Siddharth Kadian. All rights reserved.
//

import UIKit
import WebKit

class PDFVC: UIViewController, WKNavigationDelegate {
    
    let webView = WKWebView()
    var activityIndicator:UIActivityIndicatorView!
    var fileUrl: URL! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        
        let cancelBtn = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.leftBarButtonItem = cancelBtn
        addActivityIndicator()
        
        let shareBtn = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
               navigationItem.rightBarButtonItem = shareBtn
               
               
               let urlRequest = URLRequest(url: fileUrl)
               webView.load(urlRequest)
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
    
     @objc func shareAction() {
            self.loadFileAsync(url: fileUrl) { (fileUrl, error) in
            print("fileurl = \(fileUrl ?? "no url")")
            let items = [UIImage(contentsOfFile:fileUrl!)]
            let ac = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
            DispatchQueue.main.async {
                            self.present(ac, animated: true)
            }
        }
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

extension PDFVC {
     func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
