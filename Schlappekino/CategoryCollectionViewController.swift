//
//  MovieCollViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 20/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class CategoryCollectionViewController: UICollectionViewController, DataManagerProtocol, UISearchBarDelegate {

    var CatArray: Array<CategoryData> = Array<CategoryData>()
    var CatSearchArray: Array<CategoryData> = Array<CategoryData>()
    //var CurrentAlert: UIAlertController! = nil
    var SearchBar: UISearchBar!
    var InitialLoad: Bool = true
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.SearchBar = CustomSearch(parent: self, cancelHandler: #selector(CategoryCollectionViewController.cancelButtonTapped), searchHandler: #selector(CategoryCollectionViewController.searchButtonTapped))
        self.navigationItem.titleView = self.SearchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.InitialLoad) {
            self.InitialLoad = false
            let MovieMgr: DataManager = DataManager.sharedManager()
            MovieMgr.loadCategoriesAsync(delegate: self)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.CatSearchArray = self.CatArray
            self.collectionView!.reloadData()
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
            self.CatSearchArray = self.CatArray
            self.collectionView!.reloadData()
        }
        else {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
                self.CatSearchArray.removeAll(keepingCapacity: false)
                for CatData: CategoryData in self.CatArray {
                    if (CatData.Name.lowercased().range(of: Text.lowercased()) != nil || CatData.Description.lowercased().range(of: Text.lowercased()) != nil) {
                        self.CatSearchArray.append(CatData)
                    }
                }
                DispatchQueue.main.sync(execute: {
                    self.collectionView!.reloadData()
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func categoriesDidLoad(_ categories: Array<CategoryData>!) {
        self.CatArray = categories
        self.CatSearchArray = self.CatArray
        self.collectionView!.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView?) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.CatSearchArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*cell.alpha = 0.0
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            cell.alpha = 1.0
        }, completion: nil)*/
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let CategoryCell: CategoryCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollReuseID", for: indexPath) as! CategoryCollectionCell
        let CatData: CategoryData = self.CatSearchArray[indexPath.item]
        CategoryCell.loadCategoryInfo(CatData)
        return CategoryCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let MovieCollCtl: MovieCollectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "MovieCollectionViewController") as! MovieCollectionViewController
        MovieCollCtl.setCategoryInformation(self.CatSearchArray[indexPath.item])
        self.navigationController!.pushViewController(MovieCollCtl, animated: true)
    }

}
