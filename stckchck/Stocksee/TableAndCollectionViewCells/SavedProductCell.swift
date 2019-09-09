//
//  ProductCell.swift
//  stckchck
//
//  Created by Pho on 21/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class SavedProductCell: UITableViewCell {
    
    @IBOutlet weak var savedProductImageView: designableImageView!
    
    @IBOutlet weak var savedProductNameLabel: UILabel!
    
    @IBOutlet weak var savedProductDistanceLabel: UILabel!
    
    @IBOutlet weak var savedProductPriceLabel: UILabel!
    
    @IBOutlet weak var savedStoreNameLabel: UILabel!
    
    @IBOutlet weak var deleteLikedButtonOutlet: LoadableCellButton!
    
    @IBAction func deleteLikedProduct(_ sender: LoadableCellButton) {
        
        sender.showLoading()
        
        //ProfileVC is the delgate
        didPressDeleteButtonDelegate?.deleteProductViaDeleteButton(cell: self)
        
    }
    
    weak var didPressDeleteButtonDelegate: DidPressDeleteButtonDelegate?
    
    var product: Product! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        self.deleteLikedButtonOutlet.imageView?.image = UIImage(named: "DeleteCross")
        
        savedProductImageView.loadImageFrom(product: product) { [weak weakSelf = self] (image, urlString) in
            
            guard urlString == weakSelf?.product.imageURLs?.first else {
                print("deadBeef cancelled image assignment request")
                weakSelf?.savedProductImageView.image = UIImage(named: "CameraPlaceHolderImageGrey")
                return
            }
            
            weakSelf?.savedProductImageView.image = image
            
//            if success {
//                print("deadBeef loaded image in UI update")
//            } else {
//                print("deadBeef failed to load image")
//            }
            
        }
        
        savedProductNameLabel.text = "\(product.brand!) \(product.model!)"
        let roundedPrice = product.price?.roundDoubleToString()
        savedProductPriceLabel.text = "£\(roundedPrice!)"
        
        savedStoreNameLabel.text = product.shopName
        
        guard let productDistance = product.distance else {
            savedProductDistanceLabel.text = "x km"
            return
        }
        
        let productDistanceInKm = productDistance / 1000
        
        let roundedDistance = String(format: "%.2f", productDistanceInKm)
        print("deadBeef HJ (sPC) productDistanceInKm: \(productDistanceInKm)")
        print("deadBeef HJ (sPC) roundedDistance: \(roundedDistance)")
        savedProductDistanceLabel.text = "\(roundedDistance) km"
        
    }
    
}

