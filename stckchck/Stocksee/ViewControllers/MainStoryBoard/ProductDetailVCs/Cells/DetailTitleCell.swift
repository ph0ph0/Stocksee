//
//  DetailTitleCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailTitleCell: UICollectionViewCell, ListBindable {
    
    @IBOutlet weak var productTitleLabel: UILabel!
    let animationLabel = UILabel()
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailTitleVM else {
            print("deadBeef IGLK failed to make dtVM")
            return
        }
        productTitleLabel.text = viewModel.productTitle
    }
}
