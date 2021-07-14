//
//  IntelligentMoviePlayer.swift
//  Schlappekino
//
//  Created by Pit Jost on 06/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

/*if #available(iOS 9, *) {
// Then we are on iOS 9
} else {
// iOS 8 or earlier
}*/

import UIKit
import AVKit
import AVFoundation

var sharedIMPInstance: IntelligentMoviePlayer! = nil

class IntelligentMoviePlayer: NSObject, MovieDataProtocol, AVPlayerViewControllerDelegate, AVPlayerDoneViewControllerDelegate {
    
    var MoviePlayer: AVPlayer! = nil
    var MoviePlayerViewController: AVPlayerDoneViewController! = nil
    var CurrentlyPlayingMovie: MovieData! = nil
    var TimeToSeek: NSNumber? = nil
    internal var MovieTicker: Timer? = nil
    internal var PIPActive: Bool = false
    
    class func sharedPlayer() -> IntelligentMoviePlayer {
        if (sharedIMPInstance == nil) {
            sharedIMPInstance = IntelligentMoviePlayer()
        }
        return sharedIMPInstance
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if ((object is AVPlayer)) {
            let player: AVPlayer = (object as! AVPlayer)
            if ((keyPath != nil) && (keyPath == "status")) {
                player.removeObserver(self, forKeyPath: "status")
                if ((player.status == AVPlayerStatus.readyToPlay)) {
                    if (self.TimeToSeek != nil) {
                        player.seek(to: CMTimeMakeWithSeconds(self.TimeToSeek!.doubleValue, player.currentItem!.asset.duration.timescale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
                    }
                    self.MovieTicker = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(IntelligentMoviePlayer.updateTime), userInfo: nil, repeats: true)
                    player.play()
                }
            }
        }
    }
    
    func doneButtonTouchUpInside() {
        print("doneButtonTouchUpInside()")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.MoviePlayer.currentItem)
        self.MovieTicker?.invalidate()
    }
    
    func setTimeForCurrentMovie(_ time: Float64) {
        let defaults: UserDefaults = UserDefaults()
        let existingDict: NSDictionary? = defaults.dictionary(forKey: "PlaybackStore") as NSDictionary?
        var timeDict: NSMutableDictionary = NSMutableDictionary()
        if (existingDict != nil) {
            timeDict = NSMutableDictionary(dictionary: existingDict!)
        }
        timeDict.setValue(time, forKey: self.CurrentlyPlayingMovie.DatabaseID)
        defaults.setValue(timeDict, forKey: "PlaybackStore")
        defaults.synchronize()
    }
    
    @objc func updateTime() {
        self.setTimeForCurrentMovie(CMTimeGetSeconds(self.MoviePlayer.currentTime()))
    }
    
    @objc func moviePlaybackFinished(_ notification: Notification!) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.MoviePlayer.currentItem)
        self.MovieTicker?.invalidate()
        self.setTimeForCurrentMovie(Float64(0))
        self.MoviePlayerViewController.dismiss(animated: true, completion: nil)
    }
    
    func initMovie(_ movie: MovieData, fromURL url: URL) {
        self.CurrentlyPlayingMovie = movie
        self.MoviePlayer = AVPlayer(url: url)
        self.MoviePlayerViewController = AVPlayerDoneViewController()
        self.MoviePlayerViewController.doneDelegate = self
        if #available(iOS 9, *) {
            self.MoviePlayerViewController.delegate = self
        }
        self.MoviePlayerViewController.player = self.MoviePlayer
        self.MoviePlayer.addObserver(self, forKeyPath: "status", options: [], context: nil)
        let Defaults: UserDefaults = UserDefaults.standard
        let TimeDict: NSDictionary? = Defaults.object(forKey: "PlaybackStore") as? NSDictionary
        self.TimeToSeek = TimeDict?.object(forKey: movie.DatabaseID) as? NSNumber
        self.MoviePlayerViewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        UIView.getDisplayViewController().present(self.MoviePlayerViewController, animated: true, completion: {() -> Void in
            NotificationCenter.default.addObserver(self, selector: #selector(IntelligentMoviePlayer.moviePlaybackFinished(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.MoviePlayer.currentItem)
        })
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        self.PIPActive = false
        UIView.getDisplayViewController().present(self.MoviePlayerViewController, animated: true, completion: {() -> Void in
            completionHandler(true)
        })
    }
    
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        if (self.PIPActive) {
            self.PIPActive = false
            print("picture-in-picture stop")
            self.doneButtonTouchUpInside()
        }
    }
    
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        self.PIPActive = true
    }
    
    func movieRespondsOnRemote(_ movie: MovieData, success: Bool) {
        GlobalAlert.sharedAlert().closeGlobalAlert({() -> Void in
            if (success) {
                self.initMovie(movie, fromURL: movie.MovieRemoteURL)
            }
            else {
                let Alert: UIAlertController = UIAlertController(title: "Could not load movie", message: "This movie can not be displayed because it does not respond on the remote server. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                UIView.getDisplayViewController().present(Alert, animated: true, completion: {})
            }
        })
    }
    
    func playMovie(_ movie: MovieData) {
        if (movie.MovieOnDevice()) {
            self.initMovie(movie, fromURL: URL(fileURLWithPath: movie.MovieLocalPath()))
        }
        else {
            if (movie.MovieArchived) {
                let Alert: UIAlertController = UIAlertController(title: "Could not load movie", message: "This movie can not be displayed because it is not on the device and it is archived on the remote server. Please restore this movie from the remote server and try again.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                UIView.getDisplayViewController().present(Alert, animated: true, completion: {})
            }
            else {
                GlobalAlert.sharedAlert().showGlobalAlert(title: "Loading...", message: "Locating movie on remote server...", actions: nil, makeProgressView: false, completion: {() -> Void in
                    movie.MovieRespondsOnRemote(self)
                })
            }
        }
    }
    
}
