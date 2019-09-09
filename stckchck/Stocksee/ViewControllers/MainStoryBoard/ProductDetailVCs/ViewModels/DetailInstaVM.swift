//
//  DetailInstaVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailInstaVM: ListDiffable {
    
    let buttonText: String
    let instagramProfile: String
    let productDetails: Product
    
    init(buttonText: String, instagramProfile: String, productDetails: Product) {
        self.buttonText = buttonText
        self.instagramProfile = instagramProfile
        self.productDetails = productDetails
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DetailInstaVM" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailInstaVM else {return false}
        
        return buttonText == object.buttonText
    }
    
}
