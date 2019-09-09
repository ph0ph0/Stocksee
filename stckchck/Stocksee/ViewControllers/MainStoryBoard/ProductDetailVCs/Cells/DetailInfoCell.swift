//
//  DetailInfoCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailInfoCell: UICollectionViewCell, ListBindable {
    
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productShopNameLabel: UILabel!
    @IBOutlet weak var productInfoLabel: UILabel!
    @IBOutlet weak var productDistanceLabel: UILabel!
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailInfoVM else {
            print("deadBeef IGLK failed to make diVM")
            return
            
        }
        
        let roundedPrice = viewModel.price.roundDoubleToString()
        productPriceLabel.text = "£\(roundedPrice)"
        productShopNameLabel.text = viewModel.shopName
        guard viewModel.distance != nil else {
            productDistanceLabel.text = "x km"
            return
        }
        productDistanceLabel.text = "\((viewModel.distance!) / 1000) km"
        
        guard let info = viewModel.info else {
            print("deadBeef diCell no product info")
            productInfoLabel.text = "No product info"
            return
        }
        if info.isEmpty {
            productInfoLabel.text = "No product info"
        } else {
            let infoString = info.joined(separator: " ")
            productInfoLabel.text = infoString
        }
    }
}
