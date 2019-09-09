//
//  FacetCell.swift
//  stckchck
//
//  Created by Pho on 22/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import UIKit
import AlgoliaSearch

class FacetCell: UICollectionViewCell {
    
    var facetTapped: String?
    weak var didTapFacetDelegate: DidTapFacetDelegate?
    
    @IBOutlet weak var facetButtonOutlet: UIButton!
    
    @IBAction func facetButton(_ sender: Any) {
        
        print("deadBeef facet tapped")
        
        didTapFacetDelegate?.didTapFacet(at: self)
        
        facetButtonOutlet.setBackgroundImage(UIImage(named: "FacetBackgroundHighlighted"), for: .normal)
        facetButtonOutlet.setTitleColor(.white, for: .normal)
        
    }
    
    
}
