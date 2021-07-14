//
//  CurPasteClipboard.swift
//  PathFinder
//
//  Created by Pit Jost on 12/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedCPCInstance: CopyCutClipboard! = nil

enum CopyCutClipboardMode {
    case copy
    case cut
}

class CopyCutClipboard {
    
    var ClipboardUse: Bool = false
    var ClipboardMode: CopyCutClipboardMode = CopyCutClipboardMode.copy
    var ClipboardFile: FileData! = nil
    
    class func sharedClipboard() -> CopyCutClipboard {
        if (sharedCPCInstance == nil) {
            sharedCPCInstance = CopyCutClipboard()
        }
        return sharedCPCInstance
    }
    
    func setCopyAction(_ file: FileData) {
        self.ClipboardMode = CopyCutClipboardMode.copy
        self.ClipboardFile = file
        self.ClipboardUse = true
    }
    
    func setCutAction(_ file: FileData) {
        self.ClipboardMode = CopyCutClipboardMode.cut
        self.ClipboardFile = file
        self.ClipboardUse = true
    }
    
    func finalize() {
        self.ClipboardFile = nil
        self.ClipboardUse = false
    }
    
}
