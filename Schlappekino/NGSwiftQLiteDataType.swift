//
//  NGSwiftQLiteDataType.swift
//  SwiftQLite
//
//  Created by Pit Jost on 14/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import Foundation

public enum NGSwiftQLiteDataType {
    case integer
    case float
    case double
    case text
    case blob
}

public let NGSwiftQLiteDataTypeMap: Dictionary<NGSwiftQLiteDataType, String> = [
    NGSwiftQLiteDataType.blob: "BLOB",
    NGSwiftQLiteDataType.float: "REAL",
    NGSwiftQLiteDataType.double: "REAL",
    NGSwiftQLiteDataType.integer: "INTEGER",
    NGSwiftQLiteDataType.text: "TEXT"
]
