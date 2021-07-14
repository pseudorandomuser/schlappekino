//
//  SettingsManager.swift
//  Schlappekino
//
//  Created by Pit Jost on 05/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedSMInstance: SettingsManager! = nil

class SettingsManager: DataManagerProtocol, MovieLoaderProtocol {
    
    var delegate: SettingsManagerProtocol? = nil
    let artworkSyncKey: String = "autosyncArtwork"
    let databaseSyncKey: String = "autosyncDatabase"
    
    class func sharedManager() -> SettingsManager {
        if (sharedSMInstance == nil) {
            sharedSMInstance = SettingsManager()
        }
        return sharedSMInstance
    }
    
    func changeServer(_ delegate: SettingsManagerProtocol?) {
        let DisplayViewController: UIViewController! = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        let ServerHostController: UIAlertController = UIAlertController(title: "Change Server", message: "Enter the remote server host address...", preferredStyle: UIAlertControllerStyle.alert)
        ServerHostController.addTextField(configurationHandler: {textField in textField.keyboardAppearance = UIKeyboardAppearance.dark})
        ServerHostController.addAction(UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
            let ServerPortController: UIAlertController = UIAlertController(title: "Change Server", message: "Enter the remote server host port...", preferredStyle: UIAlertControllerStyle.alert)
            ServerPortController.addTextField(configurationHandler: {textField in textField.keyboardAppearance = UIKeyboardAppearance.dark})
            ServerPortController.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
                let HostAddr: String? = (ServerHostController.textFields![0] as UITextField).text
                let HostPort: Int? = Int((ServerPortController.textFields![0] as UITextField).text!)
                if ((HostAddr != nil) && (HostPort != nil)) {
                    let Defaults: UserDefaults = UserDefaults.standard
                    Defaults.setValue(HostAddr, forKey: "movieHost")
                    Defaults.setValue(HostPort, forKey: "moviePort")
                    Defaults.synchronize()
                }
                self.reloadReachabilityStatus(delegate)
            }))
            ServerPortController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
                self.reloadReachabilityStatus(delegate)
            }))
            DisplayViewController.present(ServerPortController, animated: true, completion: nil)
            }))
        ServerHostController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
            self.reloadReachabilityStatus(delegate)
        }))
        DisplayViewController.present(ServerHostController, animated: true, completion: nil)
    }
    
    func reloadReachabilityStatus(_ delegate: SettingsManagerProtocol?) {
        self.delegate = delegate
        var ActionArray: Array<UIAlertAction> = Array<UIAlertAction>()
        ActionArray.append(UIAlertAction(title: "Change Server", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
            DataManager.sharedManager().cancelReachabilityCheck()
            self.changeServer(delegate)
        }))
        if (DataManager.sharedManager().hasRemoteDb()) {
            ActionArray.append(UIAlertAction(title: "Dismiss, continue offline.", style: UIAlertActionStyle.destructive, handler: {(action: UIAlertAction!) -> Void in
                DataManager.sharedManager().cancelReachabilityCheck()
                self.delegate?.reachabilityStatusReloaded(true)
            }))
        }
        GlobalAlert.sharedAlert().showGlobalAlert(title: "Checking connection", message: "Verifying the reachability of the server...", actions: ActionArray, makeProgressView: false, completion: {
            let DataMgr: DataManager = DataManager.sharedManager()
            DataMgr.verifyRemoteReachabilityAsync(delegate: self)
        })
    }
    
   @objc  func requestedInitializationFinished(_ success: Bool) {
        if (success) {
            self.delegate?.reachabilityStatusReloaded(true)
        }
    }
   
    @objc func remoteReachabilityVerified(_ reachable: Bool) {
        GlobalAlert.sharedAlert().closeGlobalAlert({
            let HasDatabase: Bool = DataManager.sharedManager().hasRemoteDb()
            if (reachable) {
                let MovieLoader: MovieDataLoader = MovieDataLoader.sharedLoader()
                MovieLoader.setDelegate(self)
                if (HasDatabase) {
                    let Defaults: UserDefaults = UserDefaults.standard
                    let AutosyncArtwork: Bool = Defaults.bool(forKey: self.artworkSyncKey)
                    let AutosyncDatabase: Bool = Defaults.bool(forKey: self.databaseSyncKey)
                    if (AutosyncArtwork && AutosyncDatabase) {
                        MovieLoader.loadAll()
                    }
                    else if (AutosyncArtwork) {
                        MovieLoader.loadArtOnly()
                    }
                    else if (AutosyncDatabase) {
                        MovieLoader.loadDbOnly()
                    }
                    else {
                        self.delegate?.reachabilityStatusReloaded(true)
                    }
                }
                else {
                    MovieLoader.loadFirstUse()
                }
            }
            else {
                if (HasDatabase) {
                    self.delegate?.reachabilityStatusReloaded(true)
                }
                else {
                    let FailureAlert: UIAlertController = UIAlertController(title: "Failed to connect", message: "The application is missing required files. You will need to connect to the remote server at least once to be able to use this application.", preferredStyle: UIAlertControllerStyle.alert)
                    FailureAlert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
                        self.reloadReachabilityStatus(self.delegate)
                    }))
                    FailureAlert.addAction(UIAlertAction(title: "Change Server", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
                        self.changeServer(self.delegate)
                    }))
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(FailureAlert, animated: true, completion: nil)
                }
            }
        })
    }
    
}
