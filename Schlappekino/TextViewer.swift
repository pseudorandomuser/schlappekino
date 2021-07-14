//
//  TextViewer.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class TextViewer: FileHandler, UIAlertViewDelegate {
    
    var ViewController: UIViewController! = nil
    var NavController: UINavigationController! = nil
    var TextView: UITextView! = nil
    var AlertSizeTextField: UITextField! = nil
    
    var DoneButton: UIBarButtonItem! = nil
    var EditButton: UIBarButtonItem! = nil
    var SaveButtonItem: UIBarButtonItem! = nil
    var CancelButtonItem: UIBarButtonItem! = nil
    var FontSizeButton: UIBarButtonItem! = nil
    
    override init() {
        super.init(name: "Text Viewer")
        self.DoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(TextViewer.dismissModal))
        self.EditButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(TextViewer.enterEditMode))
        self.SaveButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(TextViewer.saveAndQuitEditMode))
        self.CancelButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(TextViewer.quitEditMode))
        self.FontSizeButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TextViewer.setCustomFontSize))
        self.ViewController = UIViewController()
        self.ViewController.navigationItem.leftBarButtonItem = self.EditButton
        self.ViewController.navigationItem.rightBarButtonItem = self.DoneButton
        self.NavController = UINavigationController(rootViewController: self.ViewController)
        self.NavController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.NavController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.NavController.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.TextView = UITextView(frame: self.ViewController.view.frame)
        self.TextView.text = "Loading..."
        let Toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        Toolbar.autoresizingMask = UIViewAutoresizing.flexibleWidth
        Toolbar.setItems([UIBarButtonItem(title: "-", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TextViewer.fontMinus)), UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), self.FontSizeButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TextViewer.fontPlus))], animated: false)
        self.TextView.inputAccessoryView = Toolbar
        self.TextView.backgroundColor = UIColor.white
        self.TextView.autoresizingMask = self.AllAutoresizing
        self.TextView.isSelectable = false
        self.TextView.isEditable = false
        self.TextView.backgroundColor = UIColor.viewFlipsideColor()
        self.TextView.textColor = UIColor.white
        self.FontSizeButton.title = "\(self.TextView.font!.pointSize) pt"
        self.ViewController.view.addSubview(self.TextView)
    }
    
    override func launch() {
        self.ViewController.title = self.File.fileName
        self.reloadText()
        self.getDisplayController().present(self.NavController, animated: true, completion: nil)
    }
    
    @objc func enterEditMode() {
        self.ViewController.navigationItem.setLeftBarButton(self.SaveButtonItem, animated: true)
        self.ViewController.navigationItem.setRightBarButton(self.CancelButtonItem, animated: true)
        self.TextView.isSelectable = true
        self.TextView.isEditable = true
        self.TextView.becomeFirstResponder()
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        let TextSize: Int? = Int(alertView.textField(at: 0)!.text!)
        if (TextSize != nil) {
            self.TextView.font = self.TextView.font!.withSize(CGFloat(TextSize!))
            self.FontSizeButton.title = "\(TextSize!) pt"
        }
    }
    
    @objc func setCustomFontSize() {
        let Alert: UIAlertView = UIAlertView()
        Alert.title = "Custom Font Size"
        Alert.message = "Enter a custom font size."
        Alert.addButton(withTitle: "Set")
        Alert.addButton(withTitle: "Cancel")
        Alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        Alert.delegate = self
        Alert.show()
    }
    
    @objc func fontMinus() {
        self.TextView.font = self.TextView.font!.withSize(self.TextView.font!.pointSize - 1.0)
        self.FontSizeButton.title = "\(self.TextView.font!.pointSize) pt"
    }
    
    @objc func fontPlus() {
        self.TextView.font = self.TextView.font!.withSize(self.TextView.font!.pointSize + 1.0)
        self.FontSizeButton.title = "\(self.TextView.font!.pointSize) pt"
    }
    
    func reloadText() {
        do {
            self.TextView.text = try NSString(contentsOf: self.File.fileAccessURL as URL, encoding: String.Encoding.utf8.rawValue) as String
        } catch _ {
            self.TextView.text = nil
        }
    }
    
    @objc func quitEditMode() {
        self.TextView.resignFirstResponder()
        self.TextView.isSelectable = false
        self.TextView.isEditable = false
        self.reloadText()
        self.ViewController.navigationItem.setLeftBarButton(self.EditButton, animated: true)
        self.ViewController.navigationItem.setRightBarButton(self.DoneButton, animated: true)
    }
    
    @objc func saveAndQuitEditMode() {
        let Data: Foundation.Data = self.TextView.text.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        if ((try? Data.write(to: URL(fileURLWithPath: self.File.filePath), options: [])) != nil) {
            self.quitEditMode()
        }
        else {
            let Alert: UIAlertView = UIAlertView()
            Alert.title = "Error saving file"
            Alert.message = "The file could not be saved. Please try again or hit cancel."
            Alert.addButton(withTitle: "Dismiss")
            Alert.show()
        }
    }
    
    @objc func dismissModal() {
        self.getDisplayController().dismiss(animated: true, completion: nil)
    }
    
}
