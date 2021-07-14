//
//  MovieCollectionViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 21/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class MovieCollectionViewController: UICollectionViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, DataManagerProtocol, DownloadManagerProtocol {

    fileprivate var MovieArray: Array<MovieData> = Array<MovieData>()
    //private var PanGestureRecognizer: UIScreenEdgePanGestureRecognizer! = nil
    fileprivate var MovieSearchArray: Array<MovieData> = Array<MovieData>()
    fileprivate var CatData: CategoryData! = nil
    fileprivate var SearchBar: UISearchBar! = nil
    fileprivate var PromptText: String! = "All Movies"
    //private var ReactToGesture: Bool = true
    //private var SwitchToolbar: UIToolbar! = nil
    //private var SwitchOverlay: UIView! = nil
    fileprivate var InitialLoad: Bool = true
    //private var LastSwitchState: Int = 0
    //private var FirstSwitchUse: Bool = true
    internal var LocalOnly: Bool = false
    fileprivate var RefreshControl: UIRefreshControl! = nil
    fileprivate var Queue: OperationQueue! = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Queue = OperationQueue()
        self.Queue.maxConcurrentOperationCount = 1
        self.RefreshControl = UIRefreshControl()
        self.RefreshControl.addTarget(self, action: #selector(MovieCollectionViewController.updateMovies), for: UIControlEvents.valueChanged)
        self.collectionView!.addSubview(self.RefreshControl)
        self.collectionView!.alwaysBounceVertical = true
        /*self.PanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleRightEdgeGesture")
        self.PanGestureRecognizer.edges = UIRectEdge.Right
        self.PanGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.PanGestureRecognizer)*/
        self.SearchBar = CustomSearch(parent: self, cancelHandler: #selector(MovieCollectionViewController.cancelButtonTapped), searchHandler: #selector(MovieCollectionViewController.searchButtonTapped))
        self.navigationItem.titleView = self.SearchBar
    }
    
    /*func handleRightEdgeGesture() {
        if (self.ReactToGesture) {
            self.ReactToGesture = false
            self.SwitchOverlay = UIView(frame: UIScreen.mainScreen().bounds)
            self.SwitchOverlay.backgroundColor = UIColor.clearColor()
            self.SwitchOverlay.opaque = false
            self.SwitchOverlay.autoresizingMask = (UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth)
            let DefinedToolbarWidth: CGFloat = 280.0
            let DefinedToolbarHeight: CGFloat = 44.0
            let CalculatedToolbarOffset: CGFloat = ((UIScreen.mainScreen().bounds.width - DefinedToolbarWidth) / 2)
            let CalculatedToolbarYPos: CGFloat = ((UIScreen.mainScreen().bounds.height / 2) - (DefinedToolbarHeight / 2))
            let OffscreenToolbarRect: CGRect = CGRectMake(UIScreen.mainScreen().bounds.width, CalculatedToolbarYPos, DefinedToolbarWidth, DefinedToolbarHeight)
            let OnscreenToolbarRect: CGRect = CGRectMake(CalculatedToolbarOffset, CalculatedToolbarYPos, DefinedToolbarWidth, DefinedToolbarHeight)
            self.SwitchToolbar = UIToolbar(frame: OffscreenToolbarRect)
            self.SwitchToolbar.barStyle = UIBarStyle.BlackTranslucent
            self.SwitchToolbar.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.SwitchToolbar.layer.borderWidth = 1.0
            self.SwitchToolbar.autoresizingMask = (UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin)
            self.SwitchToolbar.layer.cornerRadius = 10.0
            self.SwitchToolbar.layer.masksToBounds = true
            let ModeSwitchControl: UISegmentedControl = UISegmentedControl(items: ["All Movies", "Local Only"])
            ModeSwitchControl.frame = CGRectMake(0, 0, 200.0, 28.0)
            
            /*
                UISegmentedControlStyle is deprecated in iOS 7.0 APIs
            */
            //ModeSwitchControl.segmentedControlStyle = UISegmentedControlStyle.Plain
            
            ModeSwitchControl.addTarget(self, action: "localSwitchStateChanged:", forControlEvents: UIControlEvents.ValueChanged)
            if (self.FirstSwitchUse) {
                self.FirstSwitchUse = false
                if (!self.LocalOnly) { ModeSwitchControl.selectedSegmentIndex = 0 }
                else { ModeSwitchControl.selectedSegmentIndex = 1 }
            }
            else {
                ModeSwitchControl.selectedSegmentIndex = self.LastSwitchState
            }
            self.LastSwitchState = ModeSwitchControl.selectedSegmentIndex
            let ModeSwitchBarItem: UIBarButtonItem = UIBarButtonItem(customView: ModeSwitchControl)
            let DoneButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "localSwitchDoneButton:")
            let FlexBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            self.SwitchToolbar.setItems([FlexBarItem, ModeSwitchBarItem, DoneButtonItem, FlexBarItem], animated: false)
            self.SwitchOverlay.addSubview(self.SwitchToolbar)
            (UIApplication.sharedApplication().delegate as AppDelegate).window?.addSubview(self.SwitchOverlay)
            UIView.animateWithDuration(0.3, animations: {
                self.SwitchToolbar.frame = OnscreenToolbarRect
            })
        }
    }
    
    func localSwitchStateChanged(control: UISegmentedControl!) {
        self.LastSwitchState = control.selectedSegmentIndex
        if (control.selectedSegmentIndex == 0) {
            self.LocalOnly = false
        }
        else {
            self.LocalOnly = true
        }
        self.updateMovies()
    }*/
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DownloadManager.sharedManager().unregisterDelegate(self)
    }
    
    /*func localSwitchDoneButton(sender: AnyObject!) {
        UIView.animateWithDuration(0.3, animations: {() -> Void in
            let ToolbarFrame: CGRect = self.SwitchToolbar.frame
            self.SwitchToolbar.frame = CGRectMake(UIScreen.mainScreen().bounds.width, ToolbarFrame.origin.y, ToolbarFrame.width, ToolbarFrame.height)
        }, completion: {(complete: Bool) -> Void in
            self.ReactToGesture = true
            self.SwitchOverlay.removeFromSuperview()
        })
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        DownloadManager.sharedManager().registerDelegate(self)
        if (self.InitialLoad) {
            if ((self.CatData) != nil) {
                self.PromptText = self.CatData.Name
            }
            self.navigationItem.prompt = self.PromptText
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.MovieSearchArray = self.MovieArray
            self.collectionView!.reloadData()
            self.navigationItem.prompt = "\(self.PromptText) (\(self.MovieSearchArray.count) Movies)"
        }
    }
    
    @objc func cancelButtonTapped() {
        self.SearchBar.text = ""
        self.searchButtonTapped()
    }
    
    @objc func searchButtonTapped() {
        self.SearchBar.resignFirstResponder()
        let Text: String = self.SearchBar.text!
        if (Text == "") {
            self.MovieSearchArray = self.MovieArray
            self.collectionView!.reloadData()
            self.navigationItem.prompt = "\(self.PromptText) (\(self.MovieSearchArray.count) Movies)"
        }
        else {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
                self.MovieSearchArray.removeAll(keepingCapacity: false)
                for movie: MovieData in self.MovieArray {
                    if (movie.MovieName.lowercased().range(of: Text.lowercased()) != nil) {
                        self.MovieSearchArray.append(movie)
                    }
                }
                DispatchQueue.main.sync(execute: {
                    self.collectionView!.reloadData()
                    self.navigationItem.prompt = "\(self.PromptText) (\(self.MovieSearchArray.count) Movies)"
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setCategoryInformation(_ Data: CategoryData) {
        self.CatData = Data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.InitialLoad) {
            self.updateMovies()
            self.InitialLoad = false
        }
    }
    
    func updatedLocalStore() {
        self.updateMovies()
    }
    
    @objc func updateMovies() {
        let MovieMgr: DataManager = DataManager.sharedManager()
        MovieMgr.loadMoviesWithConditionAsync(self.createMovieQuery(), delegate: self)
    }
    
    func createMovieQuery() -> String! {
        if (self.LocalOnly) {
            var HeadString: String = "mongo_id IN \(DataManager.sharedManager().getVisualMovieIDTuple())"
            if ((self.CatData) != nil) {
                HeadString += " AND catArr LIKE '%\(self.CatData.DatabaseID)%'"
            }
            print("createMovieQuery() return \(HeadString)")
            return HeadString
        }
        if ((self.CatData) != nil) {
            print("createMovieQuery() return query")
            return "catArr LIKE '%\(self.CatData.DatabaseID)%'"
        }
        return nil
    }

    func requestedMoviesDidLoad(_ movies: Array<MovieData>!) {
        if (self.RefreshControl.isRefreshing) {
            self.RefreshControl.endRefreshing()
        }
        self.MovieArray = movies
        self.MovieSearchArray = self.MovieArray
        self.navigationItem.prompt = "\(self.PromptText) (\(self.MovieArray.count) Movies)"
        self.collectionView!.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView?) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView?, numberOfItemsInSection section: Int) -> Int {
        return self.MovieSearchArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let MovieCell: MovieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieReuseCell", for: indexPath) as! MovieCollectionViewCell
        if (indexPath.row < self.MovieSearchArray.count) {
            let MovData: MovieData = self.MovieSearchArray[indexPath.item]
            MovieCell.loadMovieInfo(MovData)
            MovieCell.setup()
            MovieCell.ParentCollectionViewController = self
        }
        return MovieCell
    }
    
    /*override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0.0
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            cell.alpha = 1.0
        }, completion: nil)
    }*/
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! MovieCollectionViewCell).unload()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let Cell: MovieCollectionViewCell = (collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell)
        Cell.cellSelectedAction()
    }
    
    @IBAction func ReloadButtonItemTouched(_ sender: AnyObject) {
        self.updateMovies()
    }
    
}
