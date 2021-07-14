//
//  FileLoader.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedFLInstance: FileLoader! = nil

class FileLoader: NSObject, UIActionSheetDelegate {
    
    var LoadingFile: FileData! = nil
    
    class func sharedLoader() -> FileLoader {
        if (sharedFLInstance == nil) {
            sharedFLInstance = FileLoader()
        }
        return sharedFLInstance
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(500) * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: {
            if (buttonIndex < FILE_HANDLERS.count) {
                if (self.LoadingFile.fileExtension != "") {
                    let Defaults: UserDefaults = UserDefaults.standard
                    var ExistDict: NSDictionary! = Defaults.dictionary(forKey: "FileExtensionHandlers") as NSDictionary!
                    if (ExistDict == nil) {
                        ExistDict = NSDictionary()
                    }
                    var ExtDictionary: NSMutableDictionary! = NSMutableDictionary(dictionary: ExistDict)
                    if (ExtDictionary == nil) {
                        ExtDictionary = NSMutableDictionary()
                    }
                    ExtDictionary.setValue(NSNumber(value: buttonIndex as Int), forKey: self.LoadingFile.fileExtension)
                    Defaults.setValue(NSDictionary(dictionary: ExtDictionary), forKey: "FileExtensionHandlers")
                    Defaults.synchronize()
                }
                if ((buttonIndex < FILE_HANDLERS.count) && (buttonIndex >= 0)) {
                    FILE_HANDLERS[buttonIndex].loadFile(self.LoadingFile).launch()
                }
            }
        })
    }
    
    func resetExtensionHandler(_ file: FileData, rect: CGRect?, view: UIView) {
        self.LoadingFile = file
        FileHandler.showChooser(file, delegate: self, rect: rect, view: view)
    }
    
    func loadFile(_ file: FileData, rect: CGRect?, view: UIView) {
        self.LoadingFile = file
        let Defaults: UserDefaults = UserDefaults.standard
        let ExtDictionary: NSDictionary! = Defaults.dictionary(forKey: "FileExtensionHandlers") as NSDictionary!
        if (ExtDictionary != nil) {
            let HandlerNumber: AnyObject! = ExtDictionary.object(forKey: file.fileExtension) as AnyObject!
            if ((file.fileExtension == "") || HandlerNumber == nil) {
                FileHandler.showChooser(file, delegate: self, rect: rect, view: view)
            }
            else {
                let Handler: Int = (HandlerNumber as! NSNumber).intValue
                FILE_HANDLERS[Handler].loadFile(file).launch()
            }
        }
        else {
            FileHandler.showChooser(file, delegate: self, rect: rect, view: view)
        }
    }
    
}
