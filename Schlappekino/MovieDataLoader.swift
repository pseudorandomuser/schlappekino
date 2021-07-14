//
//  MovieDataLoader.swift
//  Schlappekino
//
//  Created by Pit Jost on 22/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedLoaderInstance: MovieDataLoader! = nil

class MovieDataLoader: DataManagerProtocol {
    
    var Delegate: MovieLoaderProtocol! = nil
    var AlertTitle: String = "Synchronizing..."
    
    let LoadModeAll: Int = 0
    let LoadModeOnlyArt: Int = 1
    let LoadModeOnlyDb: Int = 2
    
    var CurrentLoadMode: Int = 0
    
    class func sharedLoader() -> MovieDataLoader {
        if (sharedLoaderInstance == nil) {
            sharedLoaderInstance = MovieDataLoader()
        }
        return sharedLoaderInstance
    }
    
    func setDelegate(_ delegate: MovieLoaderProtocol) {
        self.Delegate = delegate
    }
    
    func loadFirstUse() {
        self.AlertTitle = "Setting up for first use..."
        self.loadAll()
    }
    
    func loadAll() {
        self.CurrentLoadMode = self.LoadModeAll
        self.loadDb()
    }
    
    func loadDbOnly() {
        self.CurrentLoadMode = self.LoadModeOnlyDb
        self.loadDb()
    }
    
    func loadArtOnly() {
        self.CurrentLoadMode = self.LoadModeOnlyArt
        self.loadArt()
    }
    
    func loadDb() {
        GlobalAlert.sharedAlert().showGlobalAlert(title: self.AlertTitle, message: "Exporting remote database and synchronizing with device, this might take a while...", actions: nil, makeProgressView: false, completion: {
            DataManager.sharedManager().synchronizeDatabasesAsync(delegate: self)
        })
    }
    
    func loadArt() {
        GlobalAlert.sharedAlert().showGlobalAlert(title: self.AlertTitle, message: "Caching category artwork, this might take a few minutes.", actions: nil, makeProgressView: true, completion: {
            DataManager.sharedManager().cacheThumbnailsAsync(GlobalAlert.sharedAlert().getProgressView(), mode: DataManager.SYNC_CATEGORY_THUMBS, delegate: self)
        })
    }
    
    @objc func categoryThumbnailCacheCompleted(_ success: Bool) {
        GlobalAlert.sharedAlert().closeGlobalAlert({
            print("categoryThumbnailCacheCom")
            GlobalAlert.sharedAlert().showGlobalAlert(title: self.AlertTitle, message: "Caching movie artwork, this might take a while.", actions: nil, makeProgressView: true, completion: {
                DataManager.sharedManager().cacheThumbnailsAsync(GlobalAlert.sharedAlert().getProgressView(), mode: DataManager.SYNC_MOVIE_THUMBS, delegate: self)
            })
        })
    }
    
    @objc func movieThumbnailCacheCompleted(_ success: Bool) {
        GlobalAlert.sharedAlert().closeGlobalAlert(nil)
        self.Delegate.requestedInitializationFinished?(true)
    }
    
    @objc func databaseSynchronisationFinished(_ success: Bool) {
        if (self.CurrentLoadMode == self.LoadModeOnlyDb) {
            GlobalAlert.sharedAlert().closeGlobalAlert(nil)
            self.Delegate.requestedInitializationFinished?(true)
        }
        else {
            GlobalAlert.sharedAlert().closeGlobalAlert({
                self.loadArt()
            })
        }
    }
    
}
