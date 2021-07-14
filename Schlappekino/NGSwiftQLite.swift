 //
//  NGSwiftQLite.swift
//  SwiftQLite
//
//  Created by Pit Jost on 11/07/15.
//  Copyright © 2015 Pit Jost. All rights reserved.
//

import UIKit

open class NGSwiftQLite: NSObject {
    
    fileprivate static let _sharedNGSwiftQLite: NGSwiftQLite = NGSwiftQLite()
    fileprivate var currentDatabase: OpaquePointer? = nil
    fileprivate var dbIsOpen: Bool = false
    
    public override init() {
        print("NGSwiftQLite: init(): Using SQLite Legacy C Library Version \(SQLITE_VERSION)")
    }
    
    open static func sharedInstance() -> NGSwiftQLite {
        return self._sharedNGSwiftQLite
    }
    
    fileprivate func getPath(_ node: String, relativeToDocuments relative: Bool) -> URL {
        if (relative) {
            let Manager: FileManager = FileManager.default
            let DocumentsURL: URL = Manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return DocumentsURL.appendingPathComponent(node)
        }
        return URL(fileURLWithPath: node)
    }
    
    fileprivate func getCollateSuffix(_ flag: Bool) -> String {
        if (flag) {
            return " COLLATE NOCASE"
        }
        return ""
    }
    
    fileprivate func getSortSuffix(_ sort: String!) -> String {
        if (sort != nil) {
            return " ORDER BY \(sort)"
        }
        return ""
    }
    
    fileprivate func getColumnsVisualString(_ columns: Array<String>!) -> String {
        if (columns == nil) {
            return "*"
        }
        var columnsStr: String = ""
        for column in columns {
            columnsStr += column + ", "
        }
        return columnsStr.substring(to: columnsStr.characters.index(columnsStr.startIndex, offsetBy: columnsStr.characters.count - 2))
    }
    
    open func openDatabaseWithPath(_ path: String, relativeToDocuments relative: Bool, create: Bool, mode: NGSwiftQLiteMode) throws {
        if (!self.dbIsOpen) {
            var sqliteReturnCode: Int32 = SQLITE_OK
            let fileManager: FileManager = FileManager()
            let fullURL: URL = self.getPath(path, relativeToDocuments: relative)
            if (create || fileManager.fileExists(atPath: fullURL.path)) {
                switch(mode) {
                case NGSwiftQLiteMode.db_READONLY:
                    if (create) {
                        throw NGSwiftQLiteError.illegal_MODE
                    }
                    sqliteReturnCode = sqlite3_open_v2(fullURL.path, &self.currentDatabase, SQLITE_OPEN_READONLY, nil)
                    break
                case NGSwiftQLiteMode.db_READWRITE:
                    if (create) {
                        sqliteReturnCode = sqlite3_open_v2(fullURL.path, &self.currentDatabase, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
                        break
                    }
                    sqliteReturnCode = sqlite3_open_v2(fullURL.path, &self.currentDatabase, SQLITE_OPEN_READWRITE, nil)
                    break
                }
                if (sqliteReturnCode == SQLITE_OK) {
                    self.dbIsOpen = true
                    return
                }
                if (self.currentDatabase != nil) {
                    throw NGSwiftQLiteError.generic_SQLITE_ERROR(sqliteReturnCode, String(cString: sqlite3_errmsg(self.currentDatabase)))
                }
                throw NGSwiftQLiteError.generic_UNKNOWN_SQLITE_ERROR
            }
            throw NGSwiftQLiteError.file_DOES_NOT_EXIST
        }
        //throw NGSwiftQLiteError.DATABASE_IS_OPEN
    }
    
    open func closeDatabase() throws {
        if (self.dbIsOpen) {
            if (self.currentDatabase != nil) {
                let sqliteReturnCode: Int32 = sqlite3_close(self.currentDatabase)
                if (sqliteReturnCode == SQLITE_OK) {
                    self.dbIsOpen = false
                    return
                }
                throw NGSwiftQLiteError.generic_SQLITE_ERROR(sqliteReturnCode, String(cString: sqlite3_errmsg(self.currentDatabase)))
            }
            throw NGSwiftQLiteError.generic_UNKNOWN_SQLITE_ERROR
        }
        //throw NGSwiftQLiteError.DATABASE_NOT_OPEN
    }
    
    open func execQuery(statement stmt: String) throws -> NGSwiftQLiteResult {
        if (self.dbIsOpen) {
            var execStatement: OpaquePointer? = nil
            let prepareReturn: Int32 = sqlite3_prepare_v2(self.currentDatabase, stmt, -1, &execStatement, nil)
            if (prepareReturn == SQLITE_OK) {
                var stepCount: Int = 0
                var columnCount: Int = 0
                var resultArray: Array<Dictionary<String, AnyObject?>> = Array<Dictionary<String, AnyObject?>>()
                var keyArray: Array<String> = Array<String>()
                while (sqlite3_step(execStatement) == SQLITE_ROW) {
                    if (stepCount == 0) {
                        columnCount = Int(sqlite3_column_count(execStatement))
                        if (columnCount == 0) {
                            throw NGSwiftQLiteError.empty_QUERY_RESULT
                        }
                        for index in 0...columnCount - 1 {
                            let currentKeyName: String = String(cString: sqlite3_column_name(execStatement, Int32(index)))
                            keyArray.append(currentKeyName)
                        }
                    }
                    resultArray.insert(Dictionary<String, AnyObject!>(), at: stepCount)
                    for index in 0...columnCount - 1 {
                        let index32: Int32 = Int32(index)
                        let columnDatatype: Int32 = sqlite3_column_type(execStatement, index32)
                        switch (columnDatatype) {
                        case SQLITE_INTEGER:
                            let result32: Int32 = sqlite3_column_int(execStatement, index32)
                            let resultInt: Int = Int(result32)
                            resultArray[stepCount][keyArray[index]] = resultInt as AnyObject
                            break;
                        case SQLITE_FLOAT:
                            resultArray[stepCount][keyArray[index]] = Double(sqlite3_column_double(execStatement, index32)) as AnyObject
                            break
                        case SQLITE_TEXT:
                            resultArray[stepCount][keyArray[index]] = String(cString: sqlite3_column_text(execStatement, index32)) as AnyObject
                            break
                        case SQLITE_BLOB:
                            resultArray[stepCount][keyArray[index]] = nil
                            break
                        default:
                            resultArray[stepCount][keyArray[Int(index)]] = nil
                        }
                    }
                    stepCount+=1
                }
                sqlite3_finalize(execStatement)
                return NGSwiftQLiteResult(rawDbResult: resultArray)
            }
            throw NGSwiftQLiteError.invalid_QUERY
        }
        throw NGSwiftQLiteError.database_NOT_OPEN
    }
    
    open func execCmd(statement stmt: String) throws {
        if (self.dbIsOpen) {
            print("NGSwiftQLite: execCmd: \(stmt)")
            var execStatement: OpaquePointer? = nil
            let prepareReturn: Int32 = sqlite3_prepare_v2(self.currentDatabase, stmt, -1, &execStatement, nil)
            if (prepareReturn == SQLITE_OK) {
                if (sqlite3_step(execStatement) != SQLITE_ERROR) {
                    sqlite3_finalize(execStatement)
                    return
                }
                throw NGSwiftQLiteError.generic_UNKNOWN_SQLITE_ERROR
            }
            throw NGSwiftQLiteError.generic_SQLITE_ERROR(prepareReturn, String(cString: sqlite3_errmsg(self.currentDatabase)))
        }
        throw NGSwiftQLiteError.database_NOT_OPEN
    }
    
    open func databaseIsOpen() -> Bool {
        return self.dbIsOpen
    }
    
    open func getFromTable(_ table: String, columns: Array<String>!, sortBy sort: String!, ignoreCase: Bool) throws -> NGSwiftQLiteResult {
        return try self.execQuery(statement: "SELECT \(self.getColumnsVisualString(columns)) FROM \(table)" + self.getSortSuffix(sort) + self.getCollateSuffix(ignoreCase))
    }
    
    open func getFromTable(_ table: String, columns: Array<String>!, whereColumn column: String!, equals value: AnyObject!, sortBy sort: String!, ignoreCase: Bool) throws -> NGSwiftQLiteResult {
        if ((column != nil) && (value != nil)) {
            if (value is String) {
                return try self.execQuery(statement: "SELECT \(self.getColumnsVisualString(columns)) FROM \(table) WHERE \(column)='\(value)'" + self.getSortSuffix(sort) + self.getCollateSuffix(ignoreCase))
            }
            return try self.execQuery(statement: "SELECT \(self.getColumnsVisualString(columns)) FROM \(table) WHERE \(column)=\(value)" + self.getSortSuffix(sort) + self.getCollateSuffix(ignoreCase))
        }
        return try self.getFromTable(table, columns: columns, sortBy: sort, ignoreCase: ignoreCase)
    }
    
    open func dropRowFromTable(_ table: String, whereColumn column: String, equals value: AnyObject, ignoreCase: Bool) throws {
        if (value is String) {
            return try self.execCmd(statement: "DELETE FROM \(table) WHERE \(column)='\(value)'" + self.getCollateSuffix(ignoreCase))
        }
        return try self.execCmd(statement: "DELETE FROM \(table) WHERE \(column)=\(value)" + self.getCollateSuffix(ignoreCase))
    }
    
    open func dropTable(_ table: String) throws {
        return try self.execCmd(statement: "DROP TABLE IF EXISTS \(table)")
    }
    
    open func countRowsForTable(_ table: String, whereColumn column: String!, equals value: AnyObject!, ignoreCase: Bool) throws -> Int {
        if (self.dbIsOpen) {
            var execStatement: OpaquePointer? = nil
            let prepareReturn: Int32
            if ((column != nil) && (value != nil)) {
                if (value is String) {
                    prepareReturn = sqlite3_prepare_v2(self.currentDatabase, "SELECT COUNT(*) FROM \(table) WHERE \(column)='\(value)'" + self.getCollateSuffix(ignoreCase), -1, &execStatement, nil)
                }
                else {
                    prepareReturn = sqlite3_prepare_v2(self.currentDatabase, "SELECT COUNT(*) FROM \(table) WHERE \(column)=\(value)" + self.getCollateSuffix(ignoreCase), -1, &execStatement, nil)
                }
            }
            else {
                prepareReturn = sqlite3_prepare_v2(self.currentDatabase, "SELECT COUNT(*) FROM \(table)" + self.getCollateSuffix(ignoreCase), -1, &execStatement, nil)
            }
            if (prepareReturn == SQLITE_OK) {
                if (sqlite3_step(execStatement) == SQLITE_ERROR) {
                    throw NGSwiftQLiteError.generic_SQLITE_ERROR(SQLITE_ERROR, String(cString: sqlite3_errmsg(self.currentDatabase)))
                }
                let count: Int = Int(sqlite3_column_int(execStatement, 0))
                sqlite3_finalize(execStatement)
                return count
            }
            throw NGSwiftQLiteError.generic_SQLITE_ERROR(prepareReturn, nil)
        }
        throw NGSwiftQLiteError.database_NOT_OPEN
    }
    
    open func countRowsForTable(_ table: String) throws -> Int {
        return try self.countRowsForTable(table, whereColumn: nil, equals: nil, ignoreCase: false)
    }
    
    open func insertRow(_ object: Dictionary<String, AnyObject?>, intoTable table: String) throws {
        var insertQuery: String = "INSERT INTO \(table) "
        var keyTuple = "("
        var valueTuple = "("
        for (key, value) in object {
            keyTuple += "'\(key)', "
            if (value is String) {
                let escapedValue: String = (value as! String).replacingOccurrences(of: "'", with: "\'")
                valueTuple += "'\(escapedValue)', "
                continue
            }
            valueTuple += "\(value), "
        }
        keyTuple = keyTuple.substring(to: keyTuple.characters.index(keyTuple.startIndex, offsetBy: keyTuple.characters.count - 2)) + ")"
        valueTuple = valueTuple.substring(to: valueTuple.characters.index(valueTuple.startIndex, offsetBy: valueTuple.characters.count - 2)) + ")"
        insertQuery += keyTuple + " VALUES " + valueTuple
        print("NGSwiftQLite: insertRow: " + insertQuery)
        try self.execCmd(statement: insertQuery)
    }
    
    open func createTableIfNotExists(_ table: String, withColumnsAndTypes columnsAndTypes: Dictionary<String, NGSwiftQLiteDataType>, createPrimaryKey createId: Bool) throws {
        var createQuery: String
        if (createId) {
            createQuery = "CREATE TABLE IF NOT EXISTS \(table)(ID INTEGER PRIMARY KEY AUTOINCREMENT, "
        }
        else {
            createQuery = "CREATE TABLE IF NOT EXISTS \(table)("
        }
        for (key, value) in columnsAndTypes {
            createQuery += "\(key) \(NGSwiftQLiteDataTypeMap[value]!), "
        }
        createQuery = createQuery.substring(to: createQuery.characters.index(createQuery.startIndex, offsetBy: createQuery.characters.count - 2)) + ")"
        print("NGSwiftQLite: createTable: " + createQuery)
        try self.execCmd(statement: createQuery)
    }
    
}
