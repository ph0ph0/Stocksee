//
//  DetailDescriptionVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailDescriptionVM: ListDiffable {
    
    let description: String
    
    init(description: String) {
        self.description = description
        print("deadBeef productDesc: \(description)")
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DescrtipionVM" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailDescriptionVM else {return false}
        
        return description == object.description
    }
    
}
