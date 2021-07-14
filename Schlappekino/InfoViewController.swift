//
//  InfoViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 06/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoTextView: UITextView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let BackView: UIImageView = UIImageView(frame: self.view.frame)
        BackView.contentMode = UIViewContentMode.scaleAspectFill
        BackView.image = UIImage(named: "FullIcon")!.applyDarkEffect()
        BackView.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        BackView.clipsToBounds = true
        self.view.addSubview(BackView)
        self.view.sendSubview(toBack: BackView)
        
        let versionString: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildString: String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let timeString: String = Bundle.main.infoDictionary!["NGUpdateTime"] as! String
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        self.infoTextView.textStorage.append(NSAttributedString(string: "\n\nVersion \(versionString) (Build #\(buildString))\nLast updated: \(timeString)", attributes: [NSAttributedStringKey.font:UIFont(name: "Helvetica Neue", size: 16.0)!, NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.paragraphStyle:paragraphStyle]))
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
