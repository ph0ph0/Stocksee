//
//  DetailDescriptionCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailDescriptionCell: UICollectionViewCell, ListBindable {
   
    @IBOutlet weak var productDescriptionLabel: UITextView!
    
    var height: CGFloat?
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailDescriptionVM else {
            print("deadBeef IGLK failed to make ddVM")
            return
        }
        
//        if viewModel.description == "" {
//            productDescriptionLabel.text = "No product description"
//        } else {
//            productDescriptionLabel.text = viewModel.description
//        }
        productDescriptionLabel.text = viewModel.description
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var newFrame = layoutAttributes.frame
//        // note: don't change the width
//        newFrame.size.height = height!
//        layoutAttributes.frame = newFrame
//        return layoutAttributes
//    }
}
