//
//  DetailInfoVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailInfoVM: ListDiffable {
    
    let price: Double
    let shopName: String
    let info: [String]?
    let distance: Float?
    
    init(price: Double, shopName: String, info: [String]?, distance: Float) {
        self.price = price
        self.shopName = shopName
        self.info = info
        self.distance = distance
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DetailInfo" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let product = object as? Product else {return false}
        
        return price == product.price && shopName == product.shopName && distance == product.distance
    }
    
}
