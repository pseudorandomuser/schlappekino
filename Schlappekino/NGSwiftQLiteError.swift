//
//  NGSwiftQLiteError.swift
//  SwiftQLite
//
//  Created by Pit Jost on 14/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import Foundation

public enum NGSwiftQLiteError: Error {
    case file_DOES_NOT_EXIST
    case database_IS_OPEN
    case database_NOT_OPEN
    case generic_UNKNOWN_SQLITE_ERROR
    case generic_SQLITE_ERROR(Int32, String?)
    case empty_QUERY_RESULT
    case illegal_MODE
    case invalid_QUERY
}
