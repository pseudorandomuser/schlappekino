//
//  MovieLoaderProtocol.swift
//  Schlappekino
//
//  Created by Pit Jost on 22/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

@objc protocol MovieLoaderProtocol {
    
    @objc optional func requestedInitializationFinished(_ success: Bool);
    
}
