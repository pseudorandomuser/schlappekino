//
//  AVPlayerDoneViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 19/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

protocol AVPlayerDoneViewControllerDelegate {
    func doneButtonTouchUpInside()
}

class AVPlayerDoneViewController: AVPlayerViewController {

    var doneDelegate: AVPlayerDoneViewControllerDelegate? = nil
    
    func hijackButtons(_ view: UIView) {
        for subView in view.subviews {
            if (subView is UIButton) {
                let button: UIButton = (subView as! UIButton)
                if ((button.titleLabel!.text != nil) && (button.titleLabel!.text! == "Done")) {
                    button.addTarget(self, action: #selector(AVPlayerDoneViewController.doneTouched(_:)), for: UIControlEvents.touchUpInside)
                }
            }
            self.hijackButtons(subView)
        }
    }
    
    @objc func doneTouched(_ sender: AnyObject!) {
        self.doneDelegate?.doneButtonTouchUpInside()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hijackButtons(self.view)
    }
    
}
