//
//  DetailTitleVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailTitleVM: ListDiffable {
    
    let productTitle: String
    
    init(productTitle: String) {
        self.productTitle = productTitle
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DetailTitleVM" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailTitleVM else {return false}
        
        return productTitle == object.productTitle
    }
    
}
