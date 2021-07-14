//
//  RemoteTableViewController.swift
//  PathFinder
//
//  Created by Pit Jost on 10/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

enum ExplorerMode {
    case local
    case remote
}

class ExplorerTableViewController: UITableViewController, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate {

    var ExplorerPath: String = "/"
    var ExplorerFiles: Array<FileData> = Array<FileData>()
    var ExplorerActionFile: FileData! = nil
    var ExplorerExportController: UIDocumentInteractionController! = nil
    var ExplorerActionViewRect: CGRect! = nil
    var ExplorerSafetyDelayMilli: Int64 = 500
    var ListRefreshControl: UIRefreshControl! = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ListRefreshControl = UIRefreshControl()
        self.ListRefreshControl.addTarget(self, action: #selector(ExplorerTableViewController.refreshControlStarted(_:)), for: UIControlEvents.valueChanged)
        self.tableView.alwaysBounceVertical = true
        self.tableView.addSubview(self.ListRefreshControl)
    }
    
    func refreshControlStarted(_ sender: AnyObject!) {
        self.reloadFiles()
    }
    
    func prepareForPath(_ path: String) {
        self.ExplorerPath = path
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.ExplorerPath
        self.reloadFiles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (alertView.tag == -100 && buttonIndex == 0) {
            let FolderPath: String = self.ExplorerPath + "/" + alertView.textField(at: 0)!.text!
            do {
                try FileManager.default.createDirectoryAtPath(FSTools.getDocumentSub(FolderPath), withIntermediateDirectories: true, attributes: nil)
                self.reloadFiles()
            }
            catch {
                let Alert: UIAlertView = UIAlertView()
                Alert.title = "Could not create Directory"
                Alert.message = "An error has occurred while trying to create the directory."
                Alert.addButton(withTitle: "Dismiss")
                Alert.show()
            }
        }
        else if (alertView.tag == -200 && buttonIndex == 0) {
            
            do {
                try FileManager.default.moveItemAtPath(self.ExplorerActionFile.filePath, toPath: FSTools.getDocumentSub(self.ExplorerPath + "/" + alertView.textField(at: 0)!.text!))
                self.reloadFiles()
            }
            catch {
                let Alert: UIAlertView = UIAlertView()
                Alert.title = "Could not Rename"
                Alert.message = "An error has occurred while trying to rename the file/directory."
                Alert.addButton(withTitle: "Dismiss")
                Alert.show()
            }
            
        }
        else if (alertView.tag == -404) {
            self.tabBarController!.selectedIndex = 0
        }
    }
    
    func showDirCreateAlert() {
        let Alert: UIAlertView = UIAlertView()
        Alert.title = "New Directory"
        Alert.message = "Enter a name for the new directory..."
        Alert.addButton(withTitle: "Create")
        Alert.addButton(withTitle: "Cancel")
        Alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        Alert.tag = -100
        Alert.delegate = self
        Alert.show()
    }
    
    @IBAction func addButtonTouched(_ sender: AnyObject) {
        if (CopyCutClipboard.sharedClipboard().ClipboardUse) {
            let Sheet: UIActionSheet = UIActionSheet()
            Sheet.title = "Action Menu"
            Sheet.addButton(withTitle: "Paste")
            Sheet.addButton(withTitle: "Create Directory")
            Sheet.addButton(withTitle: "Cancel")
            Sheet.cancelButtonIndex = (Sheet.numberOfButtons - 1)
            Sheet.tag = -200
            Sheet.delegate = self
            if (FSTools.isPad()) {
                Sheet.show(from: sender as! UIBarButtonItem, animated: true)
                return
            }
            Sheet.show(in: self.view)
            return
        }
        self.showDirCreateAlert()
    }
    
    func reloadFiles() {
        self.ExplorerFiles = FSTools.getContentsOfDirectory(FSTools.getDocumentSub(self.ExplorerPath))
        self.tableView.reloadData()
        if (self.ListRefreshControl.isRefreshing) {
            self.ListRefreshControl.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.ExplorerFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var FileCell: FileTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "FileExplorerCell", for: indexPath) as! FileTableViewCell
        if (FileCell == nil) {
            FileCell = FileTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "FileExplorerCell")
        }
        let File: FileData = self.ExplorerFiles[indexPath.row]
        if (CopyCutClipboard.sharedClipboard().ClipboardUse && (CopyCutClipboard.sharedClipboard().ClipboardMode == CopyCutClipboardMode.cut) && (File.filePath == CopyCutClipboard.sharedClipboard().ClipboardFile.filePath)) {
            FileCell.imageView!.alpha = 0.4
        }
        else {
            FileCell.imageView!.alpha = 1.0
        }
        FileCell.loadFile(File)
        return FileCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 31.0/255.0, green: 33/255.0, blue: 36/255.0, alpha: 1.0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let File: FileData = self.ExplorerFiles[indexPath.row]
        if (File.isDirectory) {
            let Controller: ExplorerTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "FileExplorer") as! ExplorerTableViewController
            Controller.prepareForPath(self.ExplorerPath + "/" + File.fileName)
            self.navigationController!.pushViewController(Controller, animated: true)
        }
        else {
            FileLoader.sharedLoader().loadFile(File, rect: self.tableView.cellForRow(at: indexPath)!.bounds, view: self.view)
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(self.ExplorerSafetyDelayMilli * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: {
            if (actionSheet.tag == -100) {
                switch (buttonIndex) {
                case 0:
                    CopyCutClipboard.sharedClipboard().setCopyAction(self.ExplorerActionFile)
                    break
                case 1:
                    CopyCutClipboard.sharedClipboard().setCutAction(self.ExplorerActionFile)
                    self.reloadFiles()
                    break
                case 2:
                    let Alert: UIAlertView = UIAlertView()
                    Alert.title = "Rename '\(self.ExplorerActionFile.fileName)'"
                    Alert.message = "Enter a new name for the file/folder '\(self.ExplorerActionFile.fileName)'..."
                    Alert.alertViewStyle = UIAlertViewStyle.plainTextInput
                    Alert.textField(at: 0)!.text = self.ExplorerActionFile.fileName
                    Alert.addButton(withTitle: "Rename")
                    Alert.addButton(withTitle: "Cancel")
                    Alert.delegate = self
                    Alert.tag = -200
                    Alert.show()
                case 3:
                    FileLoader.sharedLoader().resetExtensionHandler(self.ExplorerActionFile, rect: self.ExplorerActionViewRect, view: self.view)
                    break
                case 4:
                    self.ExplorerExportController = UIDocumentInteractionController(url: self.ExplorerActionFile.fileAccessURL as URL)
                    self.ExplorerExportController.delegate = self
                    if (FSTools.isPad()) {
                        self.ExplorerExportController.presentOptionsMenu(from: self.ExplorerActionViewRect, in: self.view, animated: true)
                        return
                    }
                    self.ExplorerExportController.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
                    break
                default:
                    break
                }
            }
            else if (actionSheet.tag == -200) {
                switch (buttonIndex) {
                case 0:
                    let File: FileData = CopyCutClipboard.sharedClipboard().ClipboardFile
                    var Success: Bool = true
                    if (CopyCutClipboard.sharedClipboard().ClipboardMode == CopyCutClipboardMode.cut) {
                        do {
                            try FileManager.default.moveItemAtPath(File.filePath, toPath: FSTools.getDocumentSub(self.ExplorerPath + "/" + File.fileName))
                            Success = true
                        } catch _ {
                            Success = false
                        }
                    }
                    else if (CopyCutClipboard.sharedClipboard().ClipboardMode == CopyCutClipboardMode.copy) {
                        do {
                            try FileManager.default.copyItemAtPath(File.filePath, toPath: FSTools.getDocumentSub(self.ExplorerPath + "/" + File.fileName))
                            Success = true
                        } catch _ {
                            Success = false
                        }
                    }
                    if (Success) {
                        CopyCutClipboard.sharedClipboard().finalize()
                        self.reloadFiles()
                    }
                    else {
                        let Alert: UIAlertView = UIAlertView()
                        Alert.title = "Operation Failed"
                        Alert.message = "The operation could not be completed because an error occurred."
                        Alert.addButton(withTitle: "Dismiss")
                        Alert.show()
                    }
                    break
                case 1:
                    self.showDirCreateAlert()
                    break
                default:
                    break
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.ExplorerActionFile = self.ExplorerFiles[indexPath.row]
        let Sheet: UIActionSheet = UIActionSheet()
        Sheet.title = "Select an action for the file '\(self.ExplorerActionFile.fileName)'..."
        Sheet.addButton(withTitle: "Copy")
        Sheet.addButton(withTitle: "Cut")
        Sheet.addButton(withTitle: "Rename")
        Sheet.addButton(withTitle: "Open With")
        Sheet.addButton(withTitle: "Export")
        Sheet.addButton(withTitle: "Cancel")
        Sheet.cancelButtonIndex = (Sheet.numberOfButtons - 1)
        Sheet.tag = -100
        Sheet.delegate = self
        self.ExplorerActionViewRect = self.tableView.cellForRow(at: indexPath)!.bounds
        if (FSTools.isPad()) {
            Sheet.show(from: self.ExplorerActionViewRect, in: self.view, animated: true)
            return
        }
        Sheet.show(in: self.view)
    }
    
    override func tableView(_ tableView: UITableView?, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if (self.ExplorerFiles[indexPath.row].delete()) {
                self.ExplorerFiles.remove(at: indexPath.row)
                tableView?.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
}
