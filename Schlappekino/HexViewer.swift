//
//  HexViewer.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class HexViewer: FileHandler {
    
    var ViewController: UIViewController! = nil
    var NavController: UINavigationController! = nil
    var TextView: UITextView! = nil
    
    override init() {
        super.init(name: "Hex Viewer")
        self.ViewController = UIViewController()
        self.ViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(HexViewer.dismissModal))
        self.NavController = UINavigationController(rootViewController: self.ViewController)
        self.NavController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.NavController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.NavController.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.TextView = UITextView(frame: self.ViewController.view.frame)
        self.TextView.text = "Loading..."
        self.TextView.autoresizingMask = self.AllAutoresizing
        self.TextView.isSelectable = false
        self.TextView.isEditable = false
        self.TextView.backgroundColor = UIColor.viewFlipsideColor()
        self.TextView.textColor = UIColor.white
        self.ViewController.view.addSubview(self.TextView)
    }
    
    override func launch() {
        self.TextView.text = (try! Data(contentsOf: self.File.fileAccessURL as URL)).description
        self.ViewController.title = self.File.fileName
        self.getDisplayController().present(self.NavController, animated: true, completion: nil)
    }
    
    @objc func dismissModal() {
        self.getDisplayController().dismiss(animated: true, completion: nil)
    }
    
}
