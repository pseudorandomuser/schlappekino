//
//  HomeTableViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 21/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController, DataManagerProtocol, SettingsManagerProtocol {

    @IBOutlet var animatingTVContainer: UIView!
    @IBOutlet var animatingTV: UIImageView!
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieDetails: UILabel!
    @IBOutlet var animatingTVStars: UIImageView!
    @IBOutlet var watchNowButton: UIButton!
    
    @IBOutlet var UsedSpaceLabel: UILabel!
    @IBOutlet var UsedSpaceBar: UIProgressView!
    @IBOutlet var AvailableSpaceLabel: UILabel!
    @IBOutlet var AvailableSpaceBar: UIProgressView!
    @IBOutlet var TotalMoviesLabel: UILabel!
    @IBOutlet var TotalCategoriesLabel: UILabel!
    @IBOutlet var OnlineMoviesLabel: UILabel!
    @IBOutlet var OnlineMoviesBar: UIProgressView!
    @IBOutlet var ArchivedMoviesLabel: UILabel!
    @IBOutlet var ArchivedMoviesBar: UIProgressView!
    @IBOutlet var SeenMoviesLabel: UILabel!
    @IBOutlet var SeenMoviesBar: UIProgressView!
    @IBOutlet var UnseenMoviesLabel: UILabel!
    @IBOutlet var UnseenMoviesBar: UIProgressView!
    @IBOutlet var LocalMoviesLabel: UILabel!
    
    var RefreshItem: UIRefreshControl! = nil
    var DisplayingMovies: Array<MovieData>! = nil
    var CurrentlyDisplayingMovie: Int = 0
    var InitialLoad: Bool = true
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func debug(_ sender: AnyObject) {
        
        ActivityViewController.sharedActivityViewController().show(resetView: true, completion: nil)
        
        //self.presentViewController(ActivityViewController.sharedActivityNavigationController(), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.RefreshItem = UIRefreshControl()
        self.RefreshItem.addTarget(self, action: #selector(HomeTableViewController.updateStatisticsAsync), for: UIControlEvents.valueChanged)
        self.tableView.alwaysBounceVertical = true
        self.tableView.addSubview(self.RefreshItem)
        self.animatingTV.layer.cornerRadius = 10.0
        self.animatingTV.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*if (self.InitialLoad) {
            self.InitialLoad = false
            if (!DataManager.sharedManager().hasRemoteDb()) {
                SettingsManager.sharedManager().reloadReachabilityStatus(self)
            }
            else {
                self.setup()
            }
        }*/
    }
    
    @objc func updateStatisticsAsync() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
            let UsedSpace: CLongLong = FSTools.folderSizeAtURL(FSTools.getDocumentDir())
            let AvailableSpace: CLongLong = FSTools.freeSpace()
            let AllSpace: CLongLong = FSTools.totalSpace()
            let UsedSpaceString: String = FSTools.longLongToString(UsedSpace)
            let AvailableSpaceString: String = FSTools.longLongToString(AvailableSpace)
            let NumCategories: Int = DataManager.sharedManager().numCategories()
            let NumMovies: Int = DataManager.sharedManager().numMoviesWhereColumn(nil, equals: nil, ignoreCase: false)
            let NumMoviesLocal: Int = DataManager.sharedManager().numLocalMovies()
            let NumArchMovies: Int = DataManager.sharedManager().numMoviesWhereColumn("archiv", equals: "Yes" as AnyObject, ignoreCase: true)
            let NumSeenMovies: Int = DataManager.sharedManager().numMoviesWhereColumn("seen", equals: "Yes" as AnyObject, ignoreCase: true)
            let NumOnlineMovies: Int = (NumMovies - NumArchMovies)
            let NumUnseenMovies: Int = (NumMovies - NumSeenMovies)
            let PercUsedSpace: CFloat = (CFloat(UsedSpace) / CFloat(AllSpace))
            let PercAvailableSpace: CFloat = (CFloat(AvailableSpace) / CFloat(AllSpace))
            let PercArchMovies: CFloat = (CFloat(NumArchMovies) / CFloat(NumMovies))
            let PercOnlineMovies: CFloat = (CFloat(NumOnlineMovies) / CFloat(NumMovies))
            let PercSeenMovies: CFloat = (CFloat(NumSeenMovies) / CFloat(NumMovies))
            let PercUnseenMovies: CFloat = (CFloat(NumUnseenMovies) / CFloat(NumMovies))
            DispatchQueue.main.sync(execute: {
                self.UsedSpaceLabel.text = "Used local space: \(UsedSpaceString)"
                self.UsedSpaceBar.setProgress(PercUsedSpace, animated: true)
                self.AvailableSpaceLabel.text = "Available space: \(AvailableSpaceString)"
                self.AvailableSpaceBar.setProgress(PercAvailableSpace, animated: true)
                self.TotalCategoriesLabel.text = "Total categories: \(NumCategories)"
                self.TotalMoviesLabel.text = "Total movies: \(NumMovies)"
                self.OnlineMoviesLabel.text = "Online movies: \(NumOnlineMovies)"
                self.OnlineMoviesBar.setProgress(PercOnlineMovies, animated: true)
                self.ArchivedMoviesLabel.text = "Archived movies: \(NumArchMovies)"
                self.ArchivedMoviesBar.setProgress(PercArchMovies, animated: true)
                self.SeenMoviesLabel.text = "Seen movies: \(NumSeenMovies)"
                self.SeenMoviesBar.setProgress(PercSeenMovies, animated: true)
                self.UnseenMoviesLabel.text = "Unseen movies: \(NumUnseenMovies)"
                self.UnseenMoviesBar.setProgress(PercUnseenMovies, animated: true)
                self.LocalMoviesLabel.text = "Local movies: \(NumMoviesLocal)"
                if (self.RefreshItem.isRefreshing) {
                    self.RefreshItem.endRefreshing()
                }
            })
        })
    }
    
    func setup() {
        let MovieMgr: DataManager = DataManager.sharedManager()
        MovieMgr.loadMoviesWithConditionAsync("seen='No'", delegate: self)
        self.updateStatisticsAsync()
    }
    
    @objc func transitionAnimatingTV() {
        if (self.CurrentlyDisplayingMovie < self.DisplayingMovies.count - 1) { self.CurrentlyDisplayingMovie += 1 }
        else { self.CurrentlyDisplayingMovie = 0 }
        UIView.transition(with: self.animatingTVContainer, duration: 2.0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {() -> Void in
            let MovieInfo: MovieData = self.DisplayingMovies[self.CurrentlyDisplayingMovie]
            let DocURL: URL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0] as URL
            let DocPath: String = DocURL.path
            self.animatingTV.image = UIImage(contentsOfFile: DocPath + "/MovieAssets/Thumbnails/\(MovieInfo.DatabaseID).png")
            self.movieName.text = MovieInfo.MovieName
            self.movieDetails.text = "\(MovieInfo.MovieSize) MB - \(MovieInfo.MovieDuration)"
            self.animatingTVStars.image = UIImage(named: "Rating_\(MovieInfo.MovieRating)")
            self.animatingTVStars.isHidden = false
            self.watchNowButton.isHidden = false
        }, completion: {(completed: Bool) -> Void in})
    }
    
    @IBAction func watchNowButtonTapped(_ sender: AnyObject) {
        IntelligentMoviePlayer.sharedPlayer().playMovie(self.DisplayingMovies[self.CurrentlyDisplayingMovie])
    }
    
    func requestedMoviesDidLoad(_ movies: Array<MovieData>!) {
        self.DisplayingMovies = movies
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(HomeTableViewController.transitionAnimatingTV), userInfo: nil, repeats: true).fire()
    }
    
    func reachabilityStatusReloaded(_ success: Bool) {
        if (success) {
            self.setup()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel!.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.viewFlipsideColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
