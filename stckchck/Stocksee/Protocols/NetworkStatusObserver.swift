//
//  NetworkStatusListener.swift
//  stckchck
//
//  Created by Pho on 19/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import Reachability

protocol NetworkStatusListener: class {
    
    func networkStatusDidChange(status: Reachability.Connection)
    
}
