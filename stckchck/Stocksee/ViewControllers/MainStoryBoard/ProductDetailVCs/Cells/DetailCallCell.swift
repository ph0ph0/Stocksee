//
//  DetailCallCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailCallCell: UICollectionViewCell, ListBindable {
    
    var shopPhoneNumber: String?
    var productDetails: Product?
    
    @IBAction func callButton(sender: UIButton) {
        
        guard let phoneNumber = shopPhoneNumber else {
            print("deadBeef no shop phone number")
            return
        }
        
        AnalyticsManager.sharedInstance.sendPhoneButtonTappedEvent(product: productDetails)
        
        let url: URL = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailCallVM else {
            print("deadBeef IGLK failed to make dInstaVM")
            return
        }
        
        shopPhoneNumber = viewModel.shopPhoneNumber
        productDetails = viewModel.productDetails
        
    }
    
}
