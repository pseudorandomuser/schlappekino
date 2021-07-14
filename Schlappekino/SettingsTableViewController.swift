//
//  SettingsTableViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 22/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, MovieLoaderProtocol, SettingsManagerProtocol {

    @IBOutlet weak var artworkCell: UITableViewCell!
    @IBOutlet weak var databaseCell: UITableViewCell!
    let artworkSyncKey: String = "autosyncArtwork"
    let databaseSyncKey: String = "autosyncDatabase"
    let boolValuesDict: Dictionary<Bool, String> = [true: "YES", false: "NO"]
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let Defaults: UserDefaults = UserDefaults.standard
        self.artworkCell.textLabel!.text! = self.artworkCell.textLabel!.text!.replacingOccurrences(of: "N/A", with: self.boolValuesDict[Defaults.bool(forKey: self.artworkSyncKey)]!)
        self.databaseCell.textLabel!.text! = self.databaseCell.textLabel!.text!.replacingOccurrences(of: "N/A", with: self.boolValuesDict[Defaults.bool(forKey: self.databaseSyncKey)]!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.viewFlipsideColor()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let MovieLD: MovieDataLoader = MovieDataLoader.sharedLoader()
        MovieLD.setDelegate(self)
        switch(indexPath.row) {
        case 0:
            let Defaults: UserDefaults = UserDefaults.standard
            let Value = Defaults.bool(forKey: self.artworkSyncKey)
            self.artworkCell.textLabel!.text! = self.artworkCell.textLabel!.text!.replacingOccurrences(of: self.boolValuesDict[Value]!, with: self.boolValuesDict[!Value]!)
            Defaults.set(!Value, forKey: self.artworkSyncKey)
            Defaults.synchronize()
            break
        case 1:
            let Defaults: UserDefaults = UserDefaults.standard
            let Value = Defaults.bool(forKey: self.databaseSyncKey)
            self.databaseCell.textLabel!.text! = self.databaseCell.textLabel!.text!.replacingOccurrences(of: self.boolValuesDict[Value]!, with: self.boolValuesDict[!Value]!)
            Defaults.set(!Value, forKey: self.databaseSyncKey)
            Defaults.synchronize()
            break
        case 2:
            MovieLD.loadArtOnly()
            break;
        case 3:
            MovieLD.loadDbOnly()
            break
        case 4:
            if (DataManager.sharedManager().removeArtwork()) {
                MovieLD.loadArtOnly()
            }
            else {
                let Alert: UIAlertController = UIAlertController(title: "Error", message: "The artwork data could not be deleted. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(Alert, animated: true, completion: nil)
            }
            break
        case 5:
            if (DataManager.sharedManager().removeArtwork()) {
                MovieLD.loadAll()
            }
            break
        case 6:
            let Alert: UIAlertController = UIAlertController(title: "Delete all Movies", message: "Are you sure that you want to delete all of your movies stored locally? This action can not be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
            Alert.addAction(UIAlertAction(title: "Delete All", style: UIAlertActionStyle.destructive, handler: {(action: UIAlertAction!) -> Void in
                var ScAlert: UIAlertController! = nil
                if (DataManager.sharedManager().removeMovies()) {
                    ScAlert = UIAlertController(title: "Success", message: "Your movies stored locally have been deleted successfully.", preferredStyle: UIAlertControllerStyle.alert)
                }
                else {
                    ScAlert = UIAlertController(title: "Failed", message: "An error has occurred while trying to delete your movies stored locally. Please relaunch the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                }
                ScAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(ScAlert, animated: true, completion: nil)
            }))
            Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                let Cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
                Alert.modalPresentationStyle = UIModalPresentationStyle.popover
                Alert.popoverPresentationController!.sourceView = Cell
                Alert.popoverPresentationController!.sourceRect = Cell.bounds
            }
            self.present(Alert, animated: true, completion: nil)
            break
        case 7:
            let Alert: UIAlertController = UIAlertController(title: "Reset all Data", message: "Are you sure that you want to delete all of local data? This includes saved movies, cached artwork and the remote database. WARNING: This action can not be undone, and you will need to have access to the remote server to be able to use this applicaiton again after resetting its data. Do not use this function while travelling abroad!", preferredStyle: UIAlertControllerStyle.actionSheet)
            Alert.addAction(UIAlertAction(title: "Reset all Data", style: UIAlertActionStyle.destructive, handler: {(action: UIAlertAction!) -> Void in
                var ScAlert: UIAlertController! = nil
                if (DataManager.sharedManager().resetAllData()) {
                    ScAlert = UIAlertController(title: "Success", message: "Your data has been reset successfully.", preferredStyle: UIAlertControllerStyle.alert)
                }
                else {
                    ScAlert = UIAlertController(title: "Failed", message: "An error has occurred while trying to reset your data. Please relaunch the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                }
                ScAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) -> Void in
                    SettingsManager.sharedManager().reloadReachabilityStatus(self)
                }))
                self.present(ScAlert, animated: true, completion: nil)
            }))
            Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                let Cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
                Alert.modalPresentationStyle = UIModalPresentationStyle.popover
                Alert.popoverPresentationController!.sourceView = Cell
                Alert.popoverPresentationController!.sourceRect = Cell.bounds
            }
            self.present(Alert, animated: true, completion: nil)
            break
        case 8:
            SettingsManager.sharedManager().changeServer(self)
            break
        case 9:
            let Controller: UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "FileExplorer") as UIViewController
            self.navigationController!.pushViewController(Controller, animated: true)
            break
        case 10:
            let Controller: UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "InfoViewController") as UIViewController
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                let DoneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SettingsTableViewController.dismissInfoViewPad))
                let NavController: UINavigationController = UINavigationController(rootViewController: Controller)
                NavController.navigationBar.barStyle = UIBarStyle.blackTranslucent
                NavController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                NavController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                Controller.navigationItem.setRightBarButton(DoneButton, animated: false)
                self.present(NavController, animated: true, completion: nil)
            }
            else {
                self.navigationController!.pushViewController(Controller, animated: true)
            }
            break
        default:
            break
        }
    }
    
    @objc func dismissInfoViewPad() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reachabilityStatusReloaded(_ success: Bool) { }

}
