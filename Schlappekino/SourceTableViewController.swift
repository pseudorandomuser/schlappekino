//
//  SourceTableViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 15/08/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class SourceTableViewController: UITableViewController {

    var CatData: CategoryData! = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let MovieCollCtl: MovieCollectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "MovieCollectionViewController") as! MovieCollectionViewController
        var moviesLocal: Bool = true
        if (indexPath.row == 0) {
            moviesLocal = false
        }
        MovieCollCtl.LocalOnly = moviesLocal
        self.navigationController!.pushViewController(MovieCollCtl, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.viewFlipsideColor()
    }

}
