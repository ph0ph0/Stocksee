//
//  DetailImageVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailImageVM: ListDiffable {
    
    var imageURLs: [String]
    
    init(imageURLs: [String]) {
        self.imageURLs = imageURLs
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return imageURLs[0] as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailImageVM else {return false}
        
        return imageURLs[0] == object.imageURLs[0]
    }
    
}
