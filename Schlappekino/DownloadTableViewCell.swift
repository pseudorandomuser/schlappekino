//
//  DownloadTableViewCell.swift
//  Schlappekino
//
//  Created by Pit Jost on 26/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class DownloadTableViewCell: UITableViewCell {
    
    var MovieInfo: MovieData! = nil
    var ProgressView: UIProgressView? = nil

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadMovieInfo(_ movie: MovieData) {
        self.MovieInfo = movie
        self.textLabel!.text = movie.MovieName
        self.imageView!.image = UIImage(contentsOfFile: FSTools.getDocumentSub("MovieAssets/Thumbnails/\(movie.DatabaseID).jpg"))
        self.detailTextLabel!.text = "Status: Waiting..."
        self.ProgressView = UIProgressView(frame: CGRect(x: 140, y: (self.frame.height - 12.0), width: ((self.frame.width - 130) - 20), height: 10.0))
        self.ProgressView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleRightMargin]
        self.ProgressView!.setProgress(0, animated: false)
        self.contentView.addSubview(self.ProgressView!)
    }
    
    func updateProgress(_ Progress: CFloat) {
        let TruncProgress: Int = Int(Progress * 100)
        self.ProgressView?.setProgress(Progress, animated: true)
        self.detailTextLabel!.text = "Status: Downloading... (\(TruncProgress)%)"
    }

}
