//
//  NGSwiftQLiteResult.swift
//  SwiftQLite
//
//  Created by Pit Jost on 18/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import Foundation

open class NGSwiftQLiteResult: NSObject {
    
    fileprivate var _currentIndex = -1
    fileprivate let _rawDbResult: Array<Dictionary<String, AnyObject?>>
    
    public init(rawDbResult: Array<Dictionary<String, AnyObject?>>) {
        self._rawDbResult = rawDbResult
        super.init()
    }
    
    ///Advances to the next row in the result object 
    ///and returns true or false if the end was reached or not respectively.
    open func next() -> Bool {
        if (self._currentIndex < (self._rawDbResult.count - 1)) {
            self._currentIndex += 1
            return true
        }
        return false
    }
    
    ///Gets value of specified
    open func getColumn(_ column: String) -> AnyObject! {
        return self._rawDbResult[self._currentIndex][column] as AnyObject!
    }
    
    open func getRawData() -> Array<Dictionary<String, AnyObject?>> {
        return self._rawDbResult
    }
    
}
