//
//  FileHandler.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

struct FileHandlerType {
    static let Text: Int = 0
    static let Image: Int = 1
    static let Video: Int = 2
    static let Music: Int = 3
    static let Hex: Int = 4
    static let URL: Int = 5
    static let PDF: Int = 6
}

let FILE_HANDLERS: Array<FileHandler> = [TextViewer(), ImageViewer(), VideoViewer(), HexViewer(), URLViewer(filetype_mode: FileHandlerType.URL), URLViewer(filetype_mode: FileHandlerType.PDF)]

class FileHandler: NSObject, UIActionSheetDelegate {
    
    var File: FileData! = nil
    var ViewerName: String = "Unknown File Viewer"
    
    let AllAutoresizing: (UIViewAutoresizing) = ([UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth])
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        super.init()
        self.ViewerName = name
    }
    
    func loadFile(_ file: FileData) -> FileHandler {
        self.File = file
        return self
    }
    
    func launch() { }
    
    class func showChooser(_ file: FileData, delegate: UIActionSheetDelegate, rect: CGRect?, view: UIView) {
        let Sheet: UIActionSheet = UIActionSheet()
        Sheet.title = "Open *.\(file.fileExtension) files with..."
        Sheet.delegate = delegate
        for Viewer: FileHandler in FILE_HANDLERS {
            Sheet.addButton(withTitle: Viewer.ViewerName)
        }
        Sheet.addButton(withTitle: "Cancel")
        Sheet.cancelButtonIndex = (Sheet.numberOfButtons - 1)
        if (FSTools.isPad()) {
            Sheet.show(from: rect!, in: view, animated: true)
            return
        }
        Sheet.show(in: view)
    }
    
    func getDisplayController() -> UIViewController {
        return (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController as UIViewController!
    }
    
}
