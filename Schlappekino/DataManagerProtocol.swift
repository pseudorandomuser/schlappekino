//
//  MovieDBProtocol.swift
//  Schlappekino
//
//  Created by Pit Jost on 20/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import Foundation

@objc protocol DataManagerProtocol {
    
    @objc optional func categoriesDidLoad(_ categories: Array<CategoryData>!);
    @objc optional func categoryThumbnailCacheCompleted(_ success: Bool);
    @objc optional func movieThumbnailCacheCompleted(_ success: Bool);
    @objc optional func databaseSynchronisationFinished(_ success: Bool);
    @objc optional func remoteReachabilityVerified(_ reachable: Bool);
    @objc optional func requestedMoviesDidLoad(_ movies: Array<MovieData>!);
    
}
