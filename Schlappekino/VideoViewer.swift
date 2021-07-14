//
//  VideoViewer.swift
//  PathFinder
//
//  Created by Pit Jost on 11/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class VideoViewer: FileHandler {
    
    var MoviePlayer: MPMoviePlayerViewController! = nil
    
    override init() {
        super.init(name: "Video Viewer")
    }
    
    override func launch() {
        self.MoviePlayer = MPMoviePlayerViewController(contentURL: self.File.fileAccessURL as URL!)
        self.getDisplayController().present(self.MoviePlayer, animated: true, completion: nil)
    }
    
}
