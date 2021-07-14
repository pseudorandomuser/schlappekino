//
//  DownloadManager.swift
//  Schlappekino
//
//  Created by Pit Jost on 26/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedDLInstance: DownloadManager! = nil

class DownloadManager: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var DownloadingMoviesOnQueue: Dictionary<String, MovieData> = Dictionary<String, MovieData>()
    var DownloadingMoviesDisplayCells: Dictionary<String, DownloadTableViewCell> = Dictionary<String, DownloadTableViewCell>()
    var DownloadingMoviesURLConnections: Dictionary<String, NSURLConnectionWithAttribute> = Dictionary<String, NSURLConnectionWithAttribute>()
    var DownloadingMoviesDownloadStatuses: Dictionary<String, Bool> = Dictionary<String, Bool>()
    var DownloadingMoviesDownloadReceivedSize: Dictionary<String, Int> = Dictionary<String, Int>()
    var DownloadingMoviesExpectedContentLengths: Dictionary<String, CLongLong> = Dictionary<String, CLongLong>()
    
    var DownloadInProgress: Bool = false
    var Delegates: Array<DownloadManagerProtocol> = Array<DownloadManagerProtocol>()
    var ChangingTabBarItems: Array<UITabBarItem> = Array<UITabBarItem>()
    
    class func sharedManager() -> DownloadManager {
        if (sharedDLInstance == nil) {
            sharedDLInstance = DownloadManager()
        }
        return sharedDLInstance
    }
    
    override init() {
        super.init()
        let Manager: FileManager = FileManager.default
        let Contents: [AnyObject]!
        do {
            Contents = try Manager.contentsOfDirectory(atPath: FSTools.getDocumentSub("MovieAssets/LocalStore").path) as [AnyObject]
        } catch _ {
            Contents = nil
        }
        if ((Contents) != nil) {
            for File: AnyObject in Contents {
                let FileName: String = File as! String
                if (URL(fileURLWithPath: FileName).pathExtension == "downloading") {
                    do {
                        try Manager.removeItem(atPath: FSTools.getDocumentSub("MovieAssets/LocalStore/\(FileName)").path)
                    } catch _ {
                    }
                }
            }
        }
    }
    
    func registerDelegate(_ delegate: DownloadManagerProtocol) {
        delegate.downloadsDidUpdate?()
        self.Delegates.append(delegate)
    }
    
    func unregisterDelegate(_ delegate: DownloadManagerProtocol) {
        for index in 0 ..< self.Delegates.count {
            if delegate === self.Delegates[index] {
                self.Delegates.remove(at: index)
            }
        }
    }
    
    func registerTabBarItem(_ item: UITabBarItem) {
        self.ChangingTabBarItems.append(item)
        self.updateTabBarItems()
    }
    
    func unregisterTabBarItem(_ item: UITabBarItem) {
        for index in 0 ..< self.ChangingTabBarItems.count {
            if item === self.ChangingTabBarItems[index] {
                item.badgeValue = nil
                self.ChangingTabBarItems.remove(at: index)
            }
        }
    }
    
    func registerDisplayCell(_ cell: DownloadTableViewCell, forDownload download: String) {
        if (self.DownloadingMoviesOnQueue.keys.contains(download)) {
            self.DownloadingMoviesDisplayCells.updateValue(cell, forKey: download)
        }
    }
    
    func unregisterDisplayCell(_ cell: DownloadTableViewCell) {
        for (key, value): (String, DownloadTableViewCell) in self.DownloadingMoviesDisplayCells {
            if cell === value {
                self.DownloadingMoviesDisplayCells.removeValue(forKey: key)
            }
        }
    }
    
    func notifyDelegates(_ ls: Bool) {
        for delegate: DownloadManagerProtocol in self.Delegates {
            delegate.downloadsDidUpdate?()
            if (ls) {
                delegate.updatedLocalStore?()
            }
        }
    }
    
    func numDownloads() -> Int {
        return self.DownloadingMoviesOnQueue.count
    }
    
    func downloadAtIndex(_ index: Int) -> MovieData {
        return ((Array<MovieData>(self.DownloadingMoviesOnQueue.values))[index])
    }
    
    func updateTabBarItems() {
        for item: UITabBarItem in self.ChangingTabBarItems {
            let Downloads: Int = self.numDownloads()
            if (Downloads > 0) {
                item.badgeValue = String(Downloads)
            }
            else {
                item.badgeValue = nil
            }
        }
    }
    
    func unregisterDownloadFromQueue(download: String) -> Bool {
        if (self.DownloadingMoviesOnQueue.keys.contains(download)) {
            self.DownloadingMoviesURLConnections[download]?.cancel()
            self.DownloadingMoviesOnQueue.removeValue(forKey: download)
            self.DownloadingMoviesURLConnections.removeValue(forKey: download)
            self.DownloadingMoviesDisplayCells.removeValue(forKey: download)
            self.DownloadingMoviesDownloadStatuses.removeValue(forKey: download)
            self.DownloadingMoviesDownloadReceivedSize.removeValue(forKey: download)
            self.DownloadingMoviesExpectedContentLengths.removeValue(forKey: download)
            self.DownloadingMoviesDisplayCells.removeValue(forKey: download)
            if (self.DownloadingMoviesOnQueue.count > 0) {
                self.startDownload(ConnectionID: ([String](self.DownloadingMoviesOnQueue.keys))[0])
            }
            else {
                UIApplication.shared.isIdleTimerDisabled = false
                self.DownloadInProgress = false
            }
            self.notifyDelegates(true)
            self.updateTabBarItems()
            return true
        }
        return false
    }
    
    func storePathForDownload(_ download: String, withExtension format: String, partialDownload: Bool) -> String {
        if (partialDownload) {
            return FSTools.getDocumentSub("MovieAssets/LocalStore/\(download).\(format).downloading").path
        }
        return FSTools.getDocumentSub("MovieAssets/LocalStore/\(download).\(format)").path
    }
    
    func unlinkData(download: String) -> Bool {
        let Manager: FileManager = FileManager.default
        let Format: String = self.DownloadingMoviesOnQueue[download]!.MovieFileFormat
        do {
            try Manager.removeItem(atPath: self.storePathForDownload(download, withExtension: Format, partialDownload: true))
            return true
        }
        catch {
            return false
        }
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        let ConnectionID: String = (connection as! NSURLConnectionWithAttribute).getIdentifier()
        let MovieName: String = self.DownloadingMoviesOnQueue[ConnectionID]!.MovieName
        self.unlinkData(download: ConnectionID)
        self.unregisterDownloadFromQueue(download: ConnectionID)
        GlobalAlert.sharedAlert().showGlobalAlert(title: "Download Failed", message: "The movie '\(MovieName)' could not be downloaded because an error occurred. Please try again later.", actions: [UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)], makeProgressView: false, completion: nil)
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        let ConnectionID: String = (connection as! NSURLConnectionWithAttribute).getIdentifier()
        let ExpectedLen: CLongLong = response.expectedContentLength
        let FreeSpace: CLongLong = FSTools.freeSpace()
        if (ExpectedLen > FreeSpace) {
            connection.cancel()
            let MovieName: String = self.DownloadingMoviesOnQueue[ConnectionID]!.MovieName
            self.unlinkData(download: ConnectionID)
            self.unregisterDownloadFromQueue(download: ConnectionID)
            GlobalAlert.sharedAlert().showGlobalAlert(title: "Download Failed", message: "The movie '\(MovieName)' can not be downloaded because you don't have enough free space available. You need at least \(FSTools.longLongToString(ExpectedLen - FreeSpace)) more space. Please delete a few movies and try again.", actions: [UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)], makeProgressView: false, completion: nil)
            return
        }
        self.DownloadingMoviesDownloadStatuses.updateValue(true, forKey: ConnectionID)
        self.DownloadingMoviesExpectedContentLengths.updateValue(ExpectedLen, forKey: ConnectionID)
        let FileMgr: FileManager = FileManager.default
        let MovieInfo: MovieData = self.DownloadingMoviesOnQueue[ConnectionID]!
        let MovieFilePath: String = self.storePathForDownload(ConnectionID, withExtension: MovieInfo.MovieFileFormat, partialDownload: false)
        if (FileMgr.fileExists(atPath: MovieFilePath)) {
            do {
                try FileMgr.removeItem(atPath: MovieFilePath)
            }
            catch {
                self.unregisterDownloadFromQueue(download: ConnectionID)
            }
        }
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        let ConnectionID: String = (connection as! NSURLConnectionWithAttribute).getIdentifier()
        let DownloadingMovie: MovieData = self.DownloadingMoviesOnQueue[ConnectionID]!
        let OldReceivedInfo: Int = self.DownloadingMoviesDownloadReceivedSize[ConnectionID]!
        let NewReceivedInfo: Int = OldReceivedInfo + data.count
        self.DownloadingMoviesDownloadReceivedSize.updateValue(NewReceivedInfo, forKey: ConnectionID)
        let Progress: CFloat = CFloat(NewReceivedInfo) / CFloat(self.DownloadingMoviesExpectedContentLengths[ConnectionID]!)
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        let FilePath: String = self.storePathForDownload(ConnectionID, withExtension: DownloadingMovie.MovieFileFormat, partialDownload: true)
        if (!FileManager.fileExists(atPath: FilePath)) {
            if (!FileManager.createFile(atPath: FilePath, contents: nil, attributes: nil)) {
                self.unlinkData(download: ConnectionID)
                self.unregisterDownloadFromQueue(download: ConnectionID)
                return
            }
        }
        let FileHandle: Foundation.FileHandle = Foundation.FileHandle(forWritingAtPath: FilePath)!
        FileHandle.seekToEndOfFile()
        FileHandle.write(data)
        FileHandle.closeFile()
        let DownloadCell: DownloadTableViewCell? = self.DownloadingMoviesDisplayCells[ConnectionID]
        DownloadCell?.updateProgress(Progress)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        let ConnectionID: String = (connection as! NSURLConnectionWithAttribute).getIdentifier()
        let MovieInfo: MovieData = self.DownloadingMoviesOnQueue[ConnectionID]!
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        do {
            try FileManager.moveItem(atPath: self.storePathForDownload(ConnectionID, withExtension: MovieInfo.MovieFileFormat, partialDownload: true), toPath: self.storePathForDownload(ConnectionID, withExtension: MovieInfo.MovieFileFormat, partialDownload: false))
        } catch _ {
        }
        self.unregisterDownloadFromQueue(download: ConnectionID)
    }
    
    func startDownload(ConnectionID: String) {
        self.DownloadInProgress = true
        let Connection: NSURLConnectionWithAttribute = self.DownloadingMoviesURLConnections[ConnectionID]!
        Connection.start()
    }
    
    func registerDownloadToQueue(movie: MovieData) {
        let MovieID: String = movie.DatabaseID
        let MovieURLReq: URLRequest = URLRequest(url: movie.MovieRemoteURL as URL)
        let MovieURLConn: NSURLConnectionWithAttribute = NSURLConnectionWithAttribute(request: MovieURLReq, delegate: self, startImmediately: false, id: MovieID, attr: nil)!
        self.DownloadingMoviesOnQueue.updateValue(movie, forKey: MovieID)
        self.DownloadingMoviesDownloadStatuses.updateValue(false, forKey: MovieID)
        self.DownloadingMoviesExpectedContentLengths.updateValue(0, forKey: MovieID)
        self.DownloadingMoviesDownloadReceivedSize.updateValue(0, forKey: MovieID)
        self.DownloadingMoviesURLConnections.updateValue(MovieURLConn, forKey: MovieID)
        self.notifyDelegates(false)
        self.updateTabBarItems()
        UIApplication.shared.isIdleTimerDisabled = true
        if (!self.DownloadInProgress) {
            self.startDownload(ConnectionID: MovieID)
        }
    }
    
}
