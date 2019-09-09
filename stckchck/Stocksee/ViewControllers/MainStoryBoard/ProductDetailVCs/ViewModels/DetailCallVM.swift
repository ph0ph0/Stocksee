//
//  DetailCallVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailCallVM: ListDiffable {
    
    let shopPhoneNumber: String
    let productDetails: Product
    
    init(shopPhoneNumber: String, productDetails: Product) {
        self.shopPhoneNumber = shopPhoneNumber
        self.productDetails = productDetails
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DetailCallVM" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailCallVM else {return false}
        
        return shopPhoneNumber == object.shopPhoneNumber
    }
    
}
