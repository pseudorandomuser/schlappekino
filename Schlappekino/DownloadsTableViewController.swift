//
//  DownloadsTableViewController.swift
//  Schlappekino
//
//  Created by Pit Jost on 26/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class DownloadsTableViewController: UITableViewController, DownloadManagerProtocol {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DownloadManager.sharedManager().registerDelegate(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DownloadManager.sharedManager().unregisterDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func downloadsDidUpdate() {
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return DownloadManager.sharedManager().numDownloads()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.viewFlipsideColor()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var DownloadCell: DownloadTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath) as? DownloadTableViewCell
        if (DownloadCell == nil) {
            DownloadCell = DownloadTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "DownloadCell")
        }
        let CurrentData: MovieData = DownloadManager.sharedManager().downloadAtIndex(indexPath.row)
        DownloadCell.loadMovieInfo(CurrentData)
        DownloadManager.sharedManager().registerDisplayCell(DownloadCell, forDownload: CurrentData.DatabaseID)
        return DownloadCell as UITableViewCell
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DownloadManager.sharedManager().unregisterDisplayCell(cell as! DownloadTableViewCell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
