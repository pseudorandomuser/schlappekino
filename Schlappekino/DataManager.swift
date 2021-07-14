//
//  MovieDBManager.swift
//  Schlappekino
//
//  Created by Pit Jost on 20/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

var sharedInstance: DataManager! = nil

class DataManager: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    fileprivate let CAT_THUMBNAILS: Int = 0
    fileprivate let MOV_THUMBNAILS: Int = 1
    fileprivate let MOV_STORE: Int = 2
    
    internal static let SYNC_MOVIE_THUMBS = 0
    internal static let SYNC_CATEGORY_THUMBS = 1
    
    fileprivate var Paths: Array<String> = ["CategoryAssets/Thumbnails", "MovieAssets/Thumbnails", "MovieAssets/LocalStore"]
    fileprivate var WebAPIExportPath: String = "movies/lib/dbMoviesExportDb.jsp"
    fileprivate var WebAPIDatabasePath: String = "movies/sqlite/movies.sqlite"
    fileprivate var WebAPIMovieThumbnailPath: String = "movies/style/images/thumbs/${MovieID}/${ThumbnailNumber}.jpg"
    fileprivate var WebAPICategoryThumbnailPath: String = "movies/style/images/${ThumbnailName}"
    fileprivate var WebAPIRemoteMovieURL: String = "data/${EscapedMovieFilename}"
    fileprivate var RemoteLibraryName: String = "RemoteLibrary.db"
    fileprivate var ReachabilityConnection: NSURLConnectionWithAttribute? = nil
    fileprivate var ReachabilityCheckAborted: Bool = false
    fileprivate var OperationQueue: Foundation.OperationQueue! = nil
    
    class func sharedManager() -> DataManager {
        if (sharedInstance == nil) {
            sharedInstance = DataManager()
        }
        return sharedInstance
    }
    
    override init() {
        self.OperationQueue = Foundation.OperationQueue()
        self.OperationQueue.maxConcurrentOperationCount = 1
    }
    
    func getHostAddr() -> String {
        let Defaults: UserDefaults = UserDefaults.standard
        if (Defaults.object(forKey: "movieHost") == nil) {
            return "macserver.local"
        }
        return Defaults.string(forKey: "movieHost")!
    }
    
    func getHostPort() -> Int {
        let StoredPort: Int! = UserDefaults.standard.integer(forKey: "moviePort")
        if (StoredPort == 0) {
            return 8081
        }
        return StoredPort
    }
    
    func verifyRemoteReachabilityAsync(delegate: DataManagerProtocol?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.ReachabilityCheckAborted = false
        let ReachabilityURL: URL = URL(string: "http://\(self.getHostAddr()):\(self.getHostPort())")!
        let ReachabilityURLRequest: URLRequest = URLRequest(url: ReachabilityURL)
        self.ReachabilityConnection = NSURLConnectionWithAttribute(request: ReachabilityURLRequest, delegate: self, id: "reachabilityConnection", attr: delegate)
        self.ReachabilityConnection?.start()
    }
    
    func cancelReachabilityCheck() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.ReachabilityCheckAborted = true
        self.ReachabilityConnection?.cancel()
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        let Connection: NSURLConnectionWithAttribute? = (connection as? NSURLConnectionWithAttribute)
        if (Connection?.identifier == "reachabilityConnection") {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            connection.cancel()
            if (!self.ReachabilityCheckAborted) {
                Connection?.getAttribute()?.remoteReachabilityVerified?(true)
            }
        }
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        let Connection: NSURLConnectionWithAttribute? = (connection as? NSURLConnectionWithAttribute)
        if (Connection?.identifier == "reachabilityConnection") {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            connection.cancel()
            if (!self.ReachabilityCheckAborted) {
                Connection?.getAttribute()?.remoteReachabilityVerified?(false)
            }
        }
    }
    
    func removeArtwork() -> Bool {
        let Manager: FileManager = FileManager.default
        for AssetPath: String in self.Paths {
            if (AssetPath != self.Paths[self.MOV_STORE]) {
                do {
                    try Manager.removeItemAtPath(FSTools.getDocumentSub(AssetPath))
                }
                catch {
                    return false
                }
            }
        }
        return true
    }
    
    func removeMovies() -> Bool {
        let Manager: FileManager = FileManager.default
        do {
            let Files: [String] = try Manager.contentsOfDirectoryAtPath(FSTools.getDocumentSub(self.Paths[self.MOV_STORE]))
            for File: String in Files {
                try Manager.removeItemAtPath(FSTools.getDocumentSub("\(self.Paths[self.MOV_STORE])/\(File)"))
            }
            return true
        } catch _ {
            return false
        }
    }
    
    func resetAllData() -> Bool {
        let Manager: FileManager = FileManager.default
        do {
            let Files: [String] = try Manager.contentsOfDirectoryAtPath(FSTools.getDocumentDir())
            for File: String in Files {
                try Manager.removeItemAtPath(FSTools.getDocumentSub(File))
            }
            return true
        } catch _ {
            return false
        }
    }
    
    func numCategories() -> Int {
        do {
            try NGSwiftQLite.sharedInstance().openDatabaseWithPath(self.RemoteLibraryName, relativeToDocuments: true, create: false, mode: NGSwiftQLiteMode.db_READONLY)
            let categoryCount: Int = try NGSwiftQLite.sharedInstance().countRowsForTable("categories")
            try NGSwiftQLite.sharedInstance().closeDatabase()
            return categoryCount
        }
        catch {
            return 0
        }
    }
    
    func numMoviesWhereColumn(_ column: String!, equals value: AnyObject!, ignoreCase: Bool) -> Int {
        do {
            try NGSwiftQLite.sharedInstance().openDatabaseWithPath(self.RemoteLibraryName, relativeToDocuments: true, create: false, mode: NGSwiftQLiteMode.db_READONLY)
            let movieCount: Int = try NGSwiftQLite.sharedInstance().countRowsForTable("movies", whereColumn: column, equals: value, ignoreCase: ignoreCase)
            try NGSwiftQLite.sharedInstance().closeDatabase()
            return movieCount
        }
        catch {
            return 0
        }
    }
    
    func numLocalMovies() -> Int {
        var Movies: [AnyObject]! = nil
        do {
            Movies = try FileManager.default.contentsOfDirectoryAtPath(FSTools.getDocumentSub(self.Paths[self.MOV_STORE]))
        } catch _ { }
        if ((Movies) != nil) {
            return Movies.count
        }
        return 0
    }
    
    func getLocalMovieIDs() -> Array<String> {
        var MovieIDs: Array<String> = Array<String>()
        let Manager: FileManager = FileManager.default
        if (Manager.fileExistsAtPath(FSTools.getDocumentSub(self.Paths[self.MOV_STORE]))) {
            var MovieFileNames: [AnyObject]! = nil
            do {
                MovieFileNames = try FileManager.default.contentsOfDirectoryAtPath(FSTools.getDocumentSub(self.Paths[self.MOV_STORE]))
            } catch _ { }
            for MovieNameObj: AnyObject in MovieFileNames {
                let MovieName: String = (MovieNameObj as! String)
                if (!MovieName.hasPrefix(".")) {
                    MovieIDs.append(MovieName.components(separatedBy: ".")[0])
                }
            }
        }
        return MovieIDs
    }
    
    func getVisualMovieIDTuple() -> String {
        let IDs: Array<String> = self.getLocalMovieIDs()
        var VisualTuple: String = "("
        if (IDs.count > 0) {
            VisualTuple += "'" + IDs[0] + "'"
            for index in 1 ..< IDs.count {
                VisualTuple += ", '" + IDs[index] + "'"
            }
        }
        return (VisualTuple + ")")
    }
    
    func synchronizeDatabasesAsync(delegate: DataManagerProtocol?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let ExportURL: URL = URL(string: "http://\(self.getHostAddr()):\(self.getHostPort())/\(self.WebAPIExportPath)")!
        let ExportURLReq: URLRequest = URLRequest(url: ExportURL)
        NSURLConnection.sendAsynchronousRequest(ExportURLReq, queue: Foundation.OperationQueue(), completionHandler: {(response: URLResponse?, data: Data?, error: NSError?) -> Void in
            if (error == nil) {
                let SQLiteURL: URL = URL(string: "http://\(self.getHostAddr()):\(self.getHostPort())/\(self.WebAPIDatabasePath)")!
                let SQLiteURLReq: URLRequest = URLRequest(url: SQLiteURL)
                NSURLConnection.sendAsynchronousRequest(SQLiteURLReq, queue: Foundation.OperationQueue(), completionHandler: {(response: URLResponse?, data: Data?, error: NSError?) -> Void in
                    if ((error == nil) && (data != nil)) {
                        if (self.setupDirStructure()) {
                            if (data!.writeToFile(FSTools.getDocumentSub(self.RemoteLibraryName), atomically: false)) {
                                delegate?.databaseSynchronisationFinished?(true)
                                return
                            }
                        }
                    }
                    delegate?.databaseSynchronisationFinished?(false)
                } as! (URLResponse?, Data?, Error?) -> Void)
            }
            else {
                delegate?.databaseSynchronisationFinished?(false)
            }
        } as! (URLResponse?, Data?, Error?) -> Void)
    }
    
    func getBoolFromLitteral(_ value: String) -> Bool {
        if (value == "Yes") {
            return true
        }
        return false
    }
    
    func loadCategoriesAsync(delegate: DataManagerProtocol?) {
        self.OperationQueue.addOperation({() -> Void in
            do {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                try NGSwiftQLite.sharedInstance().openDatabaseWithPath(self.RemoteLibraryName, relativeToDocuments: true, create: false, mode: NGSwiftQLiteMode.db_READONLY)
                let dbResult: NGSwiftQLiteResult = try NGSwiftQLite.sharedInstance().getFromTable("categories", columns: nil, sortBy: "c_name", ignoreCase: true)
                try NGSwiftQLite.sharedInstance().closeDatabase()
                var catArray: Array<CategoryData> = Array<CategoryData>()
                while (dbResult.next()) {
                    let catData: CategoryData = CategoryData()
                    catData.DatabaseID = dbResult.getColumn("mongo_id") as! String
                    catData.Name = dbResult.getColumn("c_name") as! String
                    catData.Description = dbResult.getColumn("c_desc") as! String
                    catData.ThumbnailName = (((dbResult.getColumn("thumb") as! String).components(separatedBy: ".")[0]) + ".png")
                    catArray.append(catData)
                }
                DispatchQueue.main.sync(execute: {() -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    delegate?.categoriesDidLoad?(catArray)
                })
            }
            catch {
                DispatchQueue.main.sync(execute: {() -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    delegate?.categoriesDidLoad?(nil)
                })
            }
        })
    }
    
    func loadMoviesWithConditionAsync(_ condition: String!, delegate: DataManagerProtocol?) {
        self.OperationQueue.addOperation({() -> Void in
            do {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                try NGSwiftQLite.sharedInstance().openDatabaseWithPath(self.RemoteLibraryName, relativeToDocuments: true, create: false, mode: NGSwiftQLiteMode.db_READONLY)
                var query: String = "SELECT * FROM movies "
                if (condition != nil) {
                    query += "WHERE \(condition!) "
                }
                query += "ORDER BY m_name COLLATE NOCASE"
                let dbResult: NGSwiftQLiteResult = try NGSwiftQLite.sharedInstance().execQuery(statement: query)
                try NGSwiftQLite.sharedInstance().closeDatabase()
                var movieArray: Array<MovieData> = Array<MovieData>()
                while (dbResult.next()) {
                    let currentData: MovieData = MovieData()
                    currentData.DatabaseID = (dbResult.getColumn("mongo_id") as! String)
                    currentData.MovieName = (dbResult.getColumn("m_name") as! String)
                    currentData.MovieDescription = (dbResult.getColumn("m_desc") as! String)
                    currentData.MovieArchived = self.getBoolFromLitteral((dbResult.getColumn("archiv") as! String))
                    currentData.MovieDuration = (dbResult.getColumn("duration") as! String)
                    currentData.MovieRating = (dbResult.getColumn("stars") as! Int)
                    currentData.MovieSize = (dbResult.getColumn("fSize") as! Int)
                    currentData.MovieSeen = self.getBoolFromLitteral((dbResult.getColumn("seen") as! String))
                    currentData.MovieCategories = ((dbResult.getColumn("catArr") as! String)).components(separatedBy: ",")
                    currentData.MovieFileName = (dbResult.getColumn("f_name") as! String)
                    currentData.MovieFileFormat = URL(fileURLWithPath: currentData.MovieFileName).pathExtension
                    currentData.MovieRemoteURL = URL(string: "http://\(self.getHostAddr()):\(self.getHostPort())/\(self.WebAPIRemoteMovieURL)".replacingOccurrences(of: "${EscapedMovieFilename}", with: currentData.MovieFileName.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!))
                    movieArray.append(currentData)
                }
                DispatchQueue.main.sync(execute: {() -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    delegate?.requestedMoviesDidLoad?(movieArray)
                })
            }
            catch {
                DispatchQueue.main.sync(execute: {() -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    delegate?.requestedMoviesDidLoad?(nil)
                })
            }
        })
    }
    
    func hasRemoteDb() -> Bool {
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        if (FileManager.fileExistsAtPath(FSTools.getDocumentSub(self.RemoteLibraryName))) {
            return true
        }
        return false
    }
    
    func setupDirStructure() -> Bool {
        let FileManager: Foundation.FileManager = Foundation.FileManager.default
        for Struct: String in self.Paths {
            let StructPath: String = FSTools.getDocumentSub(Struct)
            if (!FileManager.fileExists(atPath: StructPath)) {
                do {
                    try FileManager.createDirectory(atPath: StructPath, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    return false
                }
            }
        }
        return true
    }
    
    fileprivate func padID(_ num: Int) -> String {
        switch (true) {
        case (num < 10):
            return "0000000\(num)"
        case (num < 100):
            return "000000\(num)"
        case (num < 1_000):
            return "00000\(num)"
        case (num < 10_000):
            return "0000\(num)"
        case (num < 100_000):
            return "000\(num)"
        case (num < 1_000_000):
            return "00\(num)"
        case (num < 10_000_000):
            return "0\(num)"
        default:
            return "\(num)"
        }
    }
    
    fileprivate func getRoundedPNGDataFromData(_ imageData: Data) -> Data? {
        let Image: UIImage? = UIImage(data: imageData)!
        let ImageFrame: CGRect = CGRect(x: 0, y: 0, width: Image!.size.width, height: Image!.size.height)
        UIGraphicsBeginImageContextWithOptions(Image!.size, false, 1.0);
        let CurrentContext: CGContext = UIGraphicsGetCurrentContext()!
        CurrentContext.setFillColor(UIColor.black.cgColor)
        CurrentContext.fill(ImageFrame)
        UIBezierPath(roundedRect: ImageFrame, cornerRadius: 10.0).addClip()
        Image!.draw(in: ImageFrame)
        let NewImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(NewImage!)
    }
    
    fileprivate func getLocalThumbPath(_ name: String, mode: Int) -> String {
        if (mode == DataManager.SYNC_MOVIE_THUMBS) {
            return FSTools.getDocumentSub("\(self.Paths[self.MOV_THUMBNAILS])/\(name).png")
        }
        return FSTools.getDocumentSub("\(self.Paths[self.CAT_THUMBNAILS])/\(name.componentsSeparatedByString(".")[0]).png")
    }
    
    fileprivate func getRemoteThumbPath(_ name: String, mode: Int) -> String {
        if (mode == DataManager.SYNC_MOVIE_THUMBS) {
            return "http://\(self.getHostAddr()):\(self.getHostPort())/\(self.WebAPIMovieThumbnailPath)".replacingOccurrences(of: "${MovieID}", with: name).replacingOccurrences(of: "${ThumbnailNumber}", with: self.padID(5))
        }
        return "http://\(self.getHostAddr()):\(self.getHostPort())/\(self.WebAPICategoryThumbnailPath)".replacingOccurrences(of: "${ThumbnailName}", with: name.addingPercentEscapes(using: String.Encoding.utf8)!)
    }
    
    func cacheThumbnailsAsync(_ progressView: UIProgressView?, mode: Int, delegate: DataManagerProtocol?) {
        self.OperationQueue.addOperation({() -> Void in
            do {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                if (self.setupDirStructure()) {
                    let table: String
                    let column: String
                    if (mode == DataManager.SYNC_MOVIE_THUMBS) { table = "movies"; column = "mongo_id" }
                    else { table = "categories"; column = "thumb" }
                    try NGSwiftQLite.sharedInstance().openDatabaseWithPath(self.RemoteLibraryName, relativeToDocuments: true, create: false, mode: NGSwiftQLiteMode.db_READONLY)
                    let fileManager: FileManager = FileManager.default
                    var missingThumbnails: Array<String> = Array<String>()
                    var allThumbnails: Array<String> = Array<String>()
                    let dbResult: NGSwiftQLiteResult = try NGSwiftQLite.sharedInstance().getFromTable(table, columns: [column], sortBy: nil, ignoreCase: false)
                    try NGSwiftQLite.sharedInstance().closeDatabase()
                    while (dbResult.next()) {
                        let thumbName: String = dbResult.getColumn(column) as! String
                        allThumbnails.append(thumbName)
                        if (!fileManager.fileExists(atPath: self.getLocalThumbPath(thumbName, mode: mode))) {
                            missingThumbnails.append(thumbName)
                        }
                    }
                    var progressCounter: Int = 0
                    for thumbName in missingThumbnails {
                        autoreleasepool(invoking: {() -> Void in
                            let currentProgress: CFloat = (CFloat(progressCounter) / CFloat(missingThumbnails.count))
                            DispatchQueue.main.sync(execute: {
                                progressView?.progress
                                progressView?.setProgress(currentProgress, animated: true)
                            })
                            if (mode == DataManager.SYNC_CATEGORY_THUMBS) {
                                print(self.getRemoteThumbPath(thumbName, mode: mode))
                            }
                            let thumbURL: URL = URL(string: self.getRemoteThumbPath(thumbName, mode: mode))!
                            let thumbData: Data? = try? Data(contentsOf: thumbURL)
                            if (thumbData != nil) {
                                if (thumbData!.count > 0) {
                                    let roundedPNG: Data? = self.getRoundedPNGDataFromData(thumbData!)
                                    try? roundedPNG!.write(to: URL(fileURLWithPath: self.getLocalThumbPath(thumbName, mode: mode)), options: [])
                                }
                            }
                            progressCounter += 1
                        })
                    }
                    DispatchQueue.main.sync(execute: {() -> Void in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if (mode == DataManager.SYNC_CATEGORY_THUMBS) {
                            delegate?.categoryThumbnailCacheCompleted?(true)
                            return
                        }
                        delegate?.movieThumbnailCacheCompleted?(true)
                    })
                    return
                }
            }
            catch { }
            DispatchQueue.main.sync(execute: {() -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if (mode == DataManager.SYNC_CATEGORY_THUMBS) {
                    delegate?.categoryThumbnailCacheCompleted?(false)
                    return
                }
                delegate?.movieThumbnailCacheCompleted?(false)
            })
        })
    }
    
}
