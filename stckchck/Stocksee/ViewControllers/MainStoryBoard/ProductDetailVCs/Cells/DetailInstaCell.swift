//
//  DetailInstaCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailInstaCell: UICollectionViewCell, ListBindable {
    
    var instagramProfile: String?
    var productDetails: Product?
    
    @IBOutlet weak var instaButtonOutlet: UIButton!
    
    @IBAction func instaButton(_ sender: Any) {
        
        guard let instagramProfile = instagramProfile else {
            print("deadBeef no instagram profile")
            return
        }
        
        AnalyticsManager.sharedInstance.sendInstagramButtonTappedEvent(product: productDetails)
        
        let url: URL = URL(string: "instagram://user?username=\(instagramProfile)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string: "http://instagram.com/\(instagramProfile)")!, options: [:], completionHandler: nil)
        }
        
        
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailInstaVM else {
            print("deadBeef IGLK failed to make dInstaVM")
            return
        }
        
        instaButtonOutlet.setTitle(viewModel.buttonText, for: .normal)
        instaButtonOutlet.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)
        instagramProfile = viewModel.instagramProfile
        
        let instaLogo = UIImage(named: "InstagramWhiteSmall")
        let instaLogoIV = setupLogoImageViewFor(button: instaButtonOutlet, logo: instaLogo!)
        instaButtonOutlet.addSubview(instaLogoIV)
        
        productDetails = viewModel.productDetails
    }
    
    func setupLogoImageViewFor(button: UIButton, logo: UIImage) -> UIImageView {
        
        let logoImageView = UIImageView()
        let x = (((button.titleLabel?.frame.minX)!) - 12) - 100
        let y = ((button.titleLabel?.frame.minY)!) - 12
        logoImageView.frame = CGRect(x: x, y: y, width: 24, height: 24)
        logoImageView.image = logo
        logoImageView.clipsToBounds = false
        logoImageView.contentMode = .scaleAspectFit
        
        return logoImageView
    }
}
