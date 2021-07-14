//
//  URLViewer.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class URLViewer: FileHandler, UIScrollViewDelegate {
    
    var ViewController: UIViewController! = nil
    var NavController: UINavigationController! = nil
    var WebView: UIWebView! = nil
    var ScrollView: UIScrollView! = nil
    var Mode: Int = 0
    
    init(filetype_mode: Int) {
        if (filetype_mode == FileHandlerType.URL) {
            super.init(name: "URL Viewer")
        }
        else if (filetype_mode == FileHandlerType.PDF) {
            super.init(name: "PDF Viewer")
        }
        else {
            super.init()
        }
        self.Mode = filetype_mode
        self.ViewController = UIViewController()
        self.ViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(URLViewer.dismissModal))
        self.NavController = UINavigationController(rootViewController: self.ViewController)
        self.NavController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.NavController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.NavController.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.WebView = UIWebView(frame: self.ViewController.view.frame)
        self.WebView.autoresizingMask = self.AllAutoresizing
        self.WebView.backgroundColor = UIColor.viewFlipsideColor()
        if (filetype_mode == FileHandlerType.URL) {
            self.ViewController.view.addSubview(self.WebView)
        }
        else if (filetype_mode == FileHandlerType.PDF) {
            self.ScrollView = UIScrollView(frame: self.ViewController.view.frame)
            self.ScrollView.delegate = self
            self.ScrollView.backgroundColor = UIColor.viewFlipsideColor()
            self.ScrollView.autoresizingMask = self.AllAutoresizing
            self.ScrollView.minimumZoomScale = 1.0
            self.ScrollView.maximumZoomScale = 6.0
            self.ScrollView.addSubview(self.WebView)
            self.ViewController.view.addSubview(self.ScrollView)
        }
    }
    
    override func launch() {
        self.ViewController.title = self.File.fileName
        if (self.Mode == FileHandlerType.URL) {
            do {
                let HTML: String = try NSString(contentsOf: self.File.fileAccessURL as URL, encoding: String.Encoding.utf8.rawValue) as String
                self.WebView.loadHTMLString(HTML, baseURL: nil)
            }
            catch {
                let Alert: UIAlertController = UIAlertController(title: "Could not open file.", message: "An error has occurred while trying to open this file. This might be caused because it does not contain valid HTML ir the encoding could not be determined, files encoded with an encoding other than UTF-8 may not work. Please verify the integrity of the file and make sure that the file's encoding corresponds to UTF-8, then try again.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.getDisplayController().present(Alert, animated: true, completion: nil)
                return
            }
        }
        else if (self.Mode == FileHandlerType.PDF) {
            let Request: URLRequest = URLRequest(url: self.File.fileAccessURL as URL)
            self.WebView.loadRequest(Request)
        }
        self.getDisplayController().present(self.NavController, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.WebView
    }
    
    @objc func dismissModal() {
        self.getDisplayController().dismiss(animated: true, completion: nil)
    }
    
}
