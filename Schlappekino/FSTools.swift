//
//  FSTools.swift
//  Schlappekino
//
//  Created by Pit Jost on 26/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class FSTools {
    
    class func getDocumentSub(_ sub: String) -> String {
        return self.getDocumentDir().appendingPathComponent(sub).absoluteString
    }
    
    class func getDocumentDir() -> URL {
        return (FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0] as URL)
    }
    
    class func isSimulator() -> Bool {
        return (self.getDocumentDir().path.range(of: "CoreSimulator") != nil)
    }
    
    class func isPad() -> Bool {
        return (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
    }
    
    class func folderSizeAtURL(_ path: URL) -> CLongLong {
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        var Size: CLongLong = 0
        for FileName: String in try! FileManager.subpathsOfDirectory(atPath: path.path) {
            do {
                let FileDictionary: NSDictionary = try FileManager.attributesOfItem(atPath: path.appendingPathComponent(FileName).path) as NSDictionary
                Size += CLongLong(FileDictionary.fileSize())
            }
            catch {
                return 0
            }
        }
        return Size
    }
    
    class func totalSpace() -> CLongLong {
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        do {
            let FileDictionary: NSDictionary = try FileManager.attributesOfFileSystem(forPath: self.getDocumentDir().path) as NSDictionary
            return (FileDictionary.object(forKey: FileAttributeKey.systemSize)! as AnyObject).int64Value
        }
        catch {
            return 0
        }
    }
    
    class func freeSpace() -> CLongLong {
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        do {
            let FileDictionary: NSDictionary = try FileManager.attributesOfFileSystem(forPath: self.getDocumentDir().path) as NSDictionary
            return (FileDictionary.object(forKey: FileAttributeKey.systemFreeSize)! as AnyObject).int64Value
        } catch {
            return 0
        }
    }
    
    class func longLongToString(_ value: CLongLong) -> String {
        let Formatter: NumberFormatter = NumberFormatter()
        Formatter.maximumFractionDigits = 2
        Formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        if (value < 1_000) {
            return "\(value) Bytes"
        }
        else if (value < 1_000_000) {
            return "\(Formatter.string(from: NSNumber(value: Double(value) / 1_000 as Double))!) Kilobytes"
        }
        else if (value < 1_000_000_000) {
            return "\(Formatter.string(from: NSNumber(value: Double(value) / 1_000_000 as Double))!) Megabytes"
        }
        return "\(Formatter.string(from: NSNumber(value: Double(value) / 1_000_000_000 as Double))!) Gigabytes"
    }
    
    class func getContentsOfDirectory(_ path: URL) -> Array<FileData>! {
        var PathContents: Array<FileData> = Array<FileData>()
        let Manager: FileManager = FileManager.default
        let Contents: [AnyObject]!
        do {
            Contents = try Manager.contentsOfDirectory(atPath: path.path) as [AnyObject]!
        } catch _ {
            Contents = nil
        }
        if (Contents != nil) {
            for File: AnyObject in Contents {
                let CurrentName: String = File as! String
                let CurrentPath: URL = path.appendingPathComponent(File as! String)
                var Directory: ObjCBool = true
                if Manager.fileExists(atPath: CurrentPath.path, isDirectory: &Directory) {
                    let FileDictionary: NSDictionary = try! Manager.attributesOfItem(atPath: CurrentPath.path) as NSDictionary
                    let MyInfo: FileData = FileData()
                    MyInfo.fileExtension = URL(fileURLWithPath: CurrentName).pathExtension
                    MyInfo.fileName = CurrentName
                    MyInfo.filePath = CurrentPath.path
                    MyInfo.fileAccessURL = CurrentPath
                    MyInfo.fileSimplePath = CurrentPath.path.replacingOccurrences(of: self.getDocumentDir().path, with: "", options: [], range: nil)
                    if (Directory.boolValue) {
                        MyInfo.fileSize = self.folderSizeAtURL(CurrentPath)
                    }
                    else {
                        MyInfo.fileSize = CLongLong(FileDictionary.fileSize())
                    }
                    MyInfo.isDirectory = Directory.boolValue
                    PathContents.append(MyInfo)
                }
            }
        }
        return PathContents
    }
    
}
