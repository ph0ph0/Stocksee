//
//  AlgoliaManager.swift
//  stckchck
//
//  Created by Pho on 24/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import AlgoliaSearch

class AlgoliaManager: NSObject {
    
    static let sharedInstance = AlgoliaManager()
    
    let client: Client
    let productsIndex: Index
    
    let appID = "KEY"
    let apiKey = "KEY"
    
    private override init() {
     
        client = Client(appID: appID, apiKey: apiKey)
        productsIndex = client.index(withName: "Products")
        
    }
    
}
