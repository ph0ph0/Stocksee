//
//  DetailOpeningVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailOpeningVM: ListDiffable {
    
    let openingTimes: String
    
    init(openingTimes: String) {
        self.openingTimes = openingTimes
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DetailOpeningVM" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailOpeningVM else {return false}
        
        return openingTimes == object.openingTimes
    }
    
}
