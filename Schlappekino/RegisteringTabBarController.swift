//
//  RegisteringTabBarController.swift
//  Schlappekino
//
//  Created by Pit Jost on 26/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class RegisteringTabBarController: UITabBarController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreNavigationController.navigationBar.barStyle = UIBarStyle.blackTranslucent
        let TableView: UITableView = self.moreNavigationController.topViewController!.view as! UITableView
        for Cell: AnyObject in TableView.visibleCells {
            (Cell as! UITableViewCell).backgroundColor = UIColor.red
        }
        for controller: AnyObject in self.viewControllers! {
            let vcontroller: UIViewController = (controller as! UIViewController)
            if (vcontroller.tabBarItem.tag == -1) {
                DownloadManager.sharedManager().registerTabBarItem(vcontroller.tabBarItem)
            }
        }
    }
    
    /*
        Function viewDidUnload() can not be overridden because it had been made unavailable.
    */
    
    /*
    override func viewDidUnload() {
        for controller: AnyObject in self.viewControllers {
            let vcontroller: UIViewController = (controller as UIViewController)
            if (vcontroller.tabBarItem.tag == -1) {
                DownloadManager.sharedManager().unregisterTabBarItem(vcontroller.tabBarItem)
            }
        }
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
