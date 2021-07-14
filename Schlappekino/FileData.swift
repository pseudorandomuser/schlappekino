//
//  FileData.swift
//  Schlappekino
//
//  Created by Pit Jost on 06/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class FileData {
    
    var fileName: String! = nil
    var filePath: String! = nil
    var fileSimplePath: String! = nil
    var fileExtension: String! = nil
    var fileSize: CLongLong = 0
    var fileAccessURL: URL! = nil
    var isDirectory: Bool = false
    
    func delete() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: self.filePath)
            return true
        } catch _ {
            return false
        }
    }
    
}
