//
//  StringBridgingExtension.swift
//  Schlappekino
//
//  Created by Pit Jost on 11/10/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import Foundation

extension String {
    var ObjCString: NSString {
        return (self as NSString)
    }
}
