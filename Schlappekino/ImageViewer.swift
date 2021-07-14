//
//  ImageViewer.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class ImageViewer: FileHandler, UIScrollViewDelegate {
    
    var ViewController: UIViewController! = nil
    var NavController: UINavigationController! = nil
    var ImageView: UIImageView! = nil
    var ScrollView: UIScrollView! = nil
    
    override init() {
        super.init(name: "Image Viewer")
        self.ViewController = UIViewController()
        self.ViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ImageViewer.dismissModal))
        self.NavController = UINavigationController(rootViewController: self.ViewController)
        self.NavController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.NavController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.NavController.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.ImageView = UIImageView(frame: self.ViewController.view.frame)
        self.ImageView.backgroundColor = UIColor.black
        self.ImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.ImageView.autoresizingMask = self.AllAutoresizing
        self.ScrollView = UIScrollView(frame: self.ViewController.view.frame)
        self.ScrollView.delegate = self
        self.ScrollView.autoresizingMask = self.AllAutoresizing
        self.ScrollView.minimumZoomScale = 1.0
        self.ScrollView.maximumZoomScale = 6.0
        self.ScrollView.addSubview(self.ImageView)
        self.ViewController.view.addSubview(self.ScrollView)
    }
    
    override func launch() {
        self.ViewController.title = self.File.fileName
        let ImageData: Data = try! Data(contentsOf: self.File.fileAccessURL as URL)
        self.ImageView.image = UIImage(data: ImageData)
        self.getDisplayController().present(self.NavController, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ImageView
    }
    
    @objc func dismissModal() {
        self.getDisplayController().dismiss(animated: true, completion: nil)
    }
    
}
