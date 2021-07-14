//
//  GlobalAlerts.swift
//  Schlappekino
//
//  Created by Pit Jost on 22/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedGAlertInstance: GlobalAlert! = nil

class GlobalAlert: NSObject, UIAlertViewDelegate {
    
    var CurrentAlert: UIAlertController! = nil
    var CurrentProgress: UIProgressView! = nil
    
    class func sharedAlert() -> GlobalAlert {
        if (sharedGAlertInstance == nil) {
            sharedGAlertInstance = GlobalAlert()
        }
        return sharedGAlertInstance
    }
    
    func showGlobalAlert(title: String, message: String, actions: Array<UIAlertAction>!, makeProgressView: Bool, completion: (() -> Void)?) {
        self.CurrentAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if (makeProgressView) {
            self.CurrentProgress = UIProgressView(frame: CGRect(x: 30.0, y: 80.0, width: 225.0, height: 90.0))
            self.CurrentAlert.view.addSubview(self.CurrentProgress)
        }
        else {
            self.CurrentProgress = nil
        }
        if ((actions) != nil) {
            for action: UIAlertAction in actions {
                self.CurrentAlert.addAction(action)
            }
        }
        UIView.getDisplayViewController().present(self.CurrentAlert, animated: true, completion: completion)
    }
    
    func closeGlobalAlert(_ completion: (() -> Void)?) {
        self.CurrentAlert.dismiss(animated: true, completion: completion)
    }
    
    func getProgressView() -> UIProgressView! {
        return self.CurrentProgress
    }
    
}
