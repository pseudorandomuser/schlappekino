//
//  DownloadManagerProtocol.swift
//  Schlappekino
//
//  Created by Pit Jost on 26/06/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

@objc protocol DownloadManagerProtocol {
    
    @objc optional func downloadsDidUpdate();
    @objc optional func updatedLocalStore();
    
}
