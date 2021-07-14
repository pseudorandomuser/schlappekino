//
//  NGSwiftQLiteVoid.swift
//  SwiftQLite
//
//  Created by Pit Jost on 14/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import Foundation

open class NGSwiftQLiteVoid: NSObject {
    
    fileprivate let _raw: Void
    
    public init(value: Void) {
        self._raw = value
        super.init()
    }
    
    open func rawValue() -> Void {
        return self._raw
    }
    
}
