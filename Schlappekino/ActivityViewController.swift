//
//  ActivityViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 19/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    fileprivate static var _sharedActivityViewController: UINavigationController! = nil
    
    static func sharedActivityNavigationController() -> UINavigationController {
        if (self._sharedActivityViewController == nil) {
            self._sharedActivityViewController = UIView.getDisplayViewController().storyboard!.instantiateViewController(withIdentifier: "ActivityNavigationController") as! UINavigationController
            self._sharedActivityViewController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self._sharedActivityViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        }
        return self._sharedActivityViewController
    }
    
    static func sharedActivityViewController() -> ActivityViewController {
        return ActivityViewController.sharedActivityNavigationController().viewControllers[0] as! ActivityViewController
    }
    
    func show(resetView reset: Bool, completion: (() -> Void)?) {
        UIView.getDisplayViewController().present(self.navigationController!, animated: true, completion: completion)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
