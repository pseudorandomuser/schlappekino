//
//  MovieData.swift
//  Schlappekino
//
//  Created by Pit Jost on 21/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

protocol MovieDataProtocol {
    
    func movieRespondsOnRemote(_ movie: MovieData, success: Bool)
    
}

class MovieData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var DatabaseID: String! = nil
    var MovieName: String! = nil
    var MovieDescription: String! = nil
    var MovieArchived: Bool = false
    var MovieDuration: String! = nil
    var MovieRating: Int! = 0
    var MovieSize: Int! = 0
    var MovieSeen: Bool = false
    var MovieCategories: [String]! = nil
    var MovieFileName: String! = nil
    var MovieFileFormat: String! = nil
    var MovieRemoteURL: URL! = nil
    var MovieDataDelegate: MovieDataProtocol? = nil
    
    func MovieLocalPath() -> String {
        return FSTools.getDocumentSub("MovieAssets/LocalStore/\(self.DatabaseID).\(self.MovieFileFormat)").path
    }
    
    func MovieOnDevice() -> Bool {
        if (FileManager.default.fileExists(atPath: self.MovieLocalPath())) {
            return true
        }
        return false
    }
    
    func MovieRespondsOnRemote(_ delegate: MovieDataProtocol?) {
        self.MovieDataDelegate = delegate
        let Request: URLRequest = URLRequest(url: self.MovieRemoteURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 2)
        print(Request)
        let Connection: NSURLConnection = NSURLConnection(request: Request, delegate: self)!
        Connection.start()
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.MovieDataDelegate?.movieRespondsOnRemote(self, success: false)
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        connection.cancel()
        if ((response as! HTTPURLResponse).statusCode == 200) {
            self.MovieDataDelegate?.movieRespondsOnRemote(self, success: true)
        }
        else {
            self.MovieDataDelegate?.movieRespondsOnRemote(self, success: false)
        }
    }
    
}
