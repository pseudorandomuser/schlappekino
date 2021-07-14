//
//  MovieCollectionViewCell.swift
//  Schlappekino
//
//  Created by Pit Jost on 21/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell, MovieDataProtocol {

    @IBOutlet var MovieInfoButton : UIButton!
    @IBOutlet var MovieRatingImage : UIImageView!
    @IBOutlet var MovieTimeSize : UILabel!
    @IBOutlet var MovieName : UILabel!
    @IBOutlet var MoviePreview : UIImageView!
    @IBOutlet var MovieInfoView: UIView!
    @IBOutlet var MovieInfoDescView: UITextView!
    @IBOutlet weak var MovieActionView: UIView!
    @IBOutlet weak var MovieActionInfoButton: UIButton!
    @IBOutlet weak var MovieActionDownloadButton: UIButton!
    @IBOutlet weak var MovieActionPlayButton: UIButton!
    @IBOutlet var MovieUnseenImage : UIImageView!
    @IBOutlet weak var MovieDownloadButton: UIButton!
    var MovieInfo: MovieData! = nil
    @IBOutlet var MovieDeleteButton: UIButton!
    var ParentCollectionViewController: MovieCollectionViewController? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup() {
        self.MovieInfoView.alpha = 0.0
        self.MovieInfoView.isHidden = true
        self.MovieInfoView.backgroundColor = UIColor.black
        self.MovieActionView.alpha = 0.0
        self.MovieActionView.isHidden = true
        self.MovieActionView.backgroundColor = UIColor.black
    }
    
    @IBAction func movieActionInfoButtonTouchUpInside(_ sender: AnyObject) {
        self.MovieInfoButtonTouched(sender)
    }
    @IBAction func movieActionDownloadButtonTouchUpInside(_ sender: AnyObject) {
        self.movieActionDoneButtonTouchUpInside(sender)
        if (self.MovieInfo.MovieOnDevice()) {
            self.MovieDeleteButtonTouched(sender)
        }
        else {
            self.MovieDownloadButtonTouched(sender)
        }
    }
    @IBAction func movieActionPlayButtonTouchUpInside(_ sender: AnyObject) {
        self.movieActionDoneButtonTouchUpInside(sender)
        IntelligentMoviePlayer.sharedPlayer().playMovie(self.MovieInfo)
    }
    
    @IBAction func movieActionDoneButtonTouchUpInside(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.MovieActionView.alpha = 0.0
            }, completion: {(completed: Bool) -> Void in
                self.MovieActionView.isHidden = true
        })
    }
    
    func loadMovieInfo(_ movie: MovieData) {
        //dispatch_async(dispatch_get_main_queue(), {
            self.MovieInfo = movie
            self.MovieName.text = movie.MovieName
            self.MovieTimeSize.text = "\(movie.MovieSize) MB - \(movie.MovieDuration)"
            self.MoviePreview.image = UIImage(contentsOfFile: FSTools.getDocumentSub("MovieAssets/Thumbnails/\(movie.DatabaseID).png").path)
            self.MoviePreview.layer.cornerRadius = 10.0
            self.MoviePreview.layer.masksToBounds = true
            self.MovieUnseenImage.isHidden = movie.MovieSeen
            self.MovieRatingImage.image = UIImage(named: "Rating_\(movie.MovieRating)")
            self.MovieInfoDescView.text = movie.MovieDescription.replacingOccurrences(of: "<u>", with: "", options: [], range: nil).replacingOccurrences(of: "</u>", with: "", options: [], range: nil).replacingOccurrences(of: "<br> ", with: "\n\n", options: [], range: nil).replacingOccurrences(of: "<br>", with: "", options: [], range: nil)
        //})
    }
    
    @IBAction func MovieInfoDoneButtonTouched(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.MovieInfoView.alpha = 0.0
        }, completion: {(completed: Bool) -> Void in
            self.MovieInfoView.isHidden = true
        })
    }
    
    @IBAction func MovieInfoButtonTouched(_ sender: AnyObject) {
        self.MovieInfoView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            UIGraphicsBeginImageContext(self.frame.size);
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let Image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!.applyDarkEffect()
            UIGraphicsEndImageContext()
            self.MovieInfoView.backgroundColor = UIColor(patternImage: Image)
            self.MovieInfoView.alpha = 1.0
        }, completion: {(completed: Bool) -> Void in
        })
    }
    
    func movieRespondsOnRemote(_ movie: MovieData, success: Bool) {
        if (success) {
            DownloadManager.sharedManager().registerDownloadToQueue(movie: self.MovieInfo)
        }
        else {
            if (self.ParentCollectionViewController != nil) {
                let Alert: UIAlertController = UIAlertController(title: "Could not download movie", message: "This movie can not be downloaded because it does not respond on the remote server. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.ParentCollectionViewController?.present(Alert, animated: true, completion: {() -> Void in
                    })
            }
        }
    }
    
    @IBAction func MovieDownloadButtonTouched(_ sender: AnyObject) {
        if (self.MovieInfo.MovieArchived) {
            if (self.ParentCollectionViewController != nil) {
                let Alert: UIAlertController = UIAlertController(title: "Could not download movie", message: "This movie can not be downloaded because it is archived on the remote server. Please restore this movie from the remote server and try again.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.ParentCollectionViewController?.present(Alert, animated: true, completion: {() -> Void in
                })
            }
        }
        else {
            self.MovieInfo.MovieRespondsOnRemote(self)
        }
    }
    
    @IBAction func MovieDeleteButtonTouched(_ sender: AnyObject) {
        if (self.ParentCollectionViewController != nil) {
            let Alert: UIAlertController = UIAlertController(title: "Delete Movie", message: "Are you sure that you want to delete the movie '\(self.MovieInfo.MovieName)' from your device? This action can not be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
            Alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action -> Void in
                
                do {
                    try FileManager.default.removeItem(atPath: self.MovieInfo.MovieLocalPath())
                    self.ParentCollectionViewController?.updateMovies()
                }
                catch {
                    let ErrorAlert: UIAlertController = UIAlertController(title: "Could not delete movie", message: "The movie '\(self.MovieInfo.MovieName)' could not be deleted from the device. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    ErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                }
                
            }))
            Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                Alert.modalPresentationStyle = UIModalPresentationStyle.popover
                Alert.popoverPresentationController!.sourceView = self
                Alert.popoverPresentationController!.sourceRect = self.bounds
            }
            self.ParentCollectionViewController?.present(Alert, animated: true, completion: nil)
        }
    }
    
    func cellSelectedAction() {
        if (self.MovieActionView.isHidden) {
            if (self.MovieInfo.MovieOnDevice()) {
                self.MovieActionDownloadButton.imageView!.image = UIImage(named: "DeleteButton")
                //self.MovieDownloadButton.hidden = true
                //self.MovieDeleteButton.hidden = false
            }
            else {
                self.MovieActionDownloadButton.imageView!.image = UIImage(named: "DownloadButton")
                //self.MovieDownloadButton.hidden = false
                //self.MovieDeleteButton.hidden = true
            }
            self.MovieActionView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                UIGraphicsBeginImageContext(self.frame.size);
                self.layer.render(in: UIGraphicsGetCurrentContext()!)
                let Image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!.applyDarkEffect()
                UIGraphicsEndImageContext()
                self.MovieActionView.backgroundColor = UIColor(patternImage: Image)
                self.MovieActionView.alpha = 1.0
                }, completion: {(completed: Bool) -> Void in
            })
        }
        //IntelligentMoviePlayer.sharedPlayer().playMovie(self.MovieInfo)
    }
    
    func unload() {
        self.MoviePreview.image = nil
    }
    
}
