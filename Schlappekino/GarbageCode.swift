//
//  GarbageCode.swift
//  Schlappekino
//
//  Created by Pit Jost on 21/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//


let ThumbID: String = CatData.ThumbnailName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
if (CatData.ThumbnailImage != nil) {
    println("Deploying category thumbnail \(ThumbID) stored in data type form...")
    CategoryCell.Thumbnail.image = CatData.ThumbnailImage
}
else {
    println("Downloading thumbnail \(ThumbID) from remote server...")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0 as CUnsignedLong), {
        
        let CCell: CategoryCollectionCell = CategoryCell
        let TID: String = ThumbID
        let CDT: CategoryData = CatData
        
        let DataMgr = DataManager.sharedInstance()
        let ThumbURL: NSURL = NSURL(string: "http://\(DataMgr.getHostAddr()):\(DataMgr.getHostPort())/movies/style/images/\(TID)")
        let ThumbData: NSData = NSData(contentsOfURL: ThumbURL)
        //Image processing starts here...
        let ThumbIMGRaw: UIImage = UIImage(data: ThumbData)
        UIGraphicsBeginImageContextWithOptions(ThumbIMGRaw.size, false, 0)
        UIBezierPath(roundedRect: CGRectMake(0, 0, ThumbIMGRaw.size.width, ThumbIMGRaw.size.height), cornerRadius: 10.0).addClip()
        ThumbIMGRaw.drawInRect(CGRectMake(0, 0, ThumbIMGRaw.size.width, ThumbIMGRaw.size.height))
        CDT.ThumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        //Image processing ends here...
        dispatch_sync(dispatch_get_main_queue(), {
            CCell.Thumbnail.image = CDT.ThumbnailImage
        })
    })
}





class func loadRepoDataSync() -> RepoData! {
    var BSONDocument: UnsafePointer<bson> = UnsafePointer.alloc(sizeof(bson))
    if (mongo_find_one(self.MongoConnection, "movies.settings", nil, nil, BSONDocument) == MONGO_OK) {
        var Data: RepoData = RepoData()
        var BSONIterator: UnsafePointer<bson_iterator> = UnsafePointer.alloc(sizeof(bson_iterator))
        bson_find(BSONIterator, BSONDocument, "http_port")
        Data.HTTPPort = Int(bson_iterator_int(BSONIterator))
        bson_find(BSONIterator, BSONDocument, "thumb_path")
        Data.ThumbnailPath = String.fromCString(bson_iterator_string(BSONIterator))
        bson_find(BSONIterator, BSONDocument, "lib_path")
        Data.MovieLibraryPath = String.fromCString(bson_iterator_string(BSONIterator))
        BSONIterator.destroy()
        BSONDocument.destroy()
        return Data
    }
    return nil
}






NSURLConnection.sendAsynchronousRequest(ReachabilityURLRequest, queue: NSOperationQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
    if (!self.ReachabilityCheckAborted) {
        if ((error == nil) && (response != nil) && (data != nil)) {
            self.LastReachabilityCheckSucceeded = true
            self.Delegate.remoteReachabilityVerified?(true)
        }
        else {
            self.LastReachabilityCheckSucceeded = false
            self.Delegate.remoteReachabilityVerified?(false)
        }
    }
})





let Alert: UIAlertController = UIAlertController(title: "Delete Movie", message: "Are you sure that you want to delete the movie '\(self.MovieInfo.MovieName)' from your device? This action can not be undone.", preferredStyle: UIAlertControllerStyle.Alert)
Alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {(action: UIAlertAction!) -> Void in
    if (NSFileManager.defaultManager().removeItemAtPath(self.MovieInfo.MovieLocalPath(), error: nil)) {
        self.ParentCollectionViewController?.updateMovies()
    }
    else {
        let ErrorAlert: UIAlertController = UIAlertController(title: "Could not delete movie", message: "The movie '\(self.MovieInfo.MovieName)' could not be deleted from the device. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        ErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
    }
}))
Alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
self.ParentCollectionViewController?.presentViewController(Alert, animated: true, completion: nil)
