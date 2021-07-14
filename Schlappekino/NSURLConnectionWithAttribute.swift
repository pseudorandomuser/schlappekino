//
//  NSURLConnectionWithID.swift
//  Schlappekino
//
//  Created by Pit Jost on 23/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class NSURLConnectionWithAttribute: NSURLConnection {
    
    var identifier: String! = nil
    var attribute: AnyObject?
    
    init?(request: URLRequest!, delegate: AnyObject!, id: String, attr: AnyObject!) {
        super.init(request: request, delegate: delegate)
        self.identifier = id
        if ((attr) != nil) {
            self.attribute = attr
        }
    }
    
    init?(request: URLRequest!, delegate: AnyObject!, startImmediately: Bool, id: String, attr: AnyObject!) {
        super.init(request: request, delegate: delegate, startImmediately: startImmediately)
        self.identifier = id
        if ((attr) != nil) {
            self.attribute = attr
        }
    }
    
    func getIdentifier() -> String {
        return self.identifier
    }
    
    func getAttribute() -> AnyObject? {
        return self.attribute
    }
    
}
