//
//  ProductCell.swift
//  stckchck
//
//  Created by Pho on 21/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Lottie

class MainFeedProductCell: UITableViewCell {
    
    var product: Product! {
        didSet {
            updateUI()
        }
    }
    
    //MARK: Properties
    
    var uid = Auth.auth().currentUser?.uid
    weak var didPressLikeButtonDelegate: DidPressLikeButtonDelegate?
    var activityIndicator = UIActivityIndicatorView()
    
    enum state {
        case liked
        case notLiked
    }
    
    var wasTapped = false
    
    var currentState: state? {
        willSet {
            print("deadBeef KK setting currentState of cell")
            likeButtonOutlet.hideLoading()
            if newValue == .liked {
                print("deadBeef KK mfPC newValue of state for button: \(String(describing: newValue))------")
                
                if wasTapped {
                    animateLikeButton()
                } else {
                    likeButtonOutlet.setImage(UIImage(named: "LikeButtonTapped"), for: .normal)
                }
            } else if newValue == .notLiked {
                print("deadBeef KK mfPC newValue of state for button: \(String(describing: newValue))------")
                
                if wasTapped {
                    animateLikedButton()
                } else {
                    likeButtonOutlet.setImage(UIImage(named: "LikeButton"), for: .normal)
                }
            }
        }
    }
    
    func setupHeartAnimationView() -> LOTAnimationView{
        let animationView = LOTAnimationView(name: "HeartAnimation")
        animationView.frame = (likeButtonOutlet.imageView?.frame)!
        animationView.center = likeButtonOutlet.convert(likeButtonOutlet.center, from: likeButtonOutlet.superview)
        animationView.bounds = (likeButtonOutlet.imageView?.bounds)!
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 2.0
        animationView.loopAnimation = false
        return animationView
    }
    
    func animateLikeButton() {
        let animationView = setupHeartAnimationView()
        wasTapped = false
        likeButtonOutlet.addSubview(animationView)
        animationView.play(fromFrame: 1, toFrame: 110) { [weak weakSelf = self] _ in
            animationView.stop()
            animationView.removeFromSuperview()
            weakSelf?.likeButtonOutlet.alpha = 0
            weakSelf?.likeButtonOutlet.setImage(UIImage(named: "LikeButtonTapped"), for: .normal)
            UIView.transition(with: (weakSelf?.likeButtonOutlet)!,
                              duration: 0.4,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {weakSelf?.likeButtonOutlet.alpha = 1}) { (success) in
                                if success {
                                    print("deadBeef mfPC_aLB showed likeButtonTapped")
                                }
            }
        }
    }

    func animateLikedButton() {
        let animationView = setupHeartAnimationView()
        wasTapped = false
        likeButtonOutlet.addSubview(animationView)
        animationView.play(fromFrame: 110, toFrame: 1) { [weak weakSelf = self] _ in
            animationView.stop()
            animationView.removeFromSuperview()
            weakSelf?.likeButtonOutlet.alpha = 0
            weakSelf?.likeButtonOutlet.setImage(UIImage(named: "LikeButton"), for: .normal)
            UIView.transition(with: (weakSelf?.likeButtonOutlet)!,
                              duration: 0.4,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {weakSelf?.likeButtonOutlet.alpha = 1}) { (success) in
                                if success {
                                    print("deadBeef mfPC_aLB showed likeButton")
                                }
            }
        }
    }

    //MARK: Outlets and Actions
    
    @IBOutlet weak var productImageView: designableImageView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productDistanceLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var likeButtonOutlet: LoadableCellButton!
    
    
    @IBAction func likeButton(_ sender: LoadableCellButton) {
        print("deadBeef likeButtonPressed ----------")
        print("deadBeef currentUser (mfpC) is \(String(describing: uid))")
        
        likeButtonOutlet.showLoading()
        didPressLikeButtonDelegate?.didPressLikeButton(at: self)
        
    }
    
    func updateUI() {
        
        uid = Auth.auth().currentUser?.uid
        
        print("deadBeef mfPC current user uid: \(String(describing: uid))")
        
        likeButtonOutlet.setImage(UIImage(named: "LikeButton"), for: .normal)
    
        
        //set the initial state of the button, otherwise app will crash
        currentState = .notLiked
        
        productImageView.image = UIImage(named: "CameraPlaceHolderImageGrey")
        
        productImageView.loadImageFrom(product: product) { [weak weakSelf = self] (image, urlString) in
            
            guard urlString == weakSelf?.product.imageURLs?.first else {
                print("deadBeef cancelled image assignment request")
                weakSelf?.productImageView.image = UIImage(named: "CameraPlaceHolderImageGrey")
                return
            }
            
            weakSelf?.productImageView.image = image
            
        }
        
        guard let brand = product.brand, let model = product.model, let roundedPrice = product.price?.roundDoubleToString() else {
            print("deadBeef couldnt get product details")
            return
        }
        
        productNameLabel.text = "\(brand) \(model)"
        productPriceLabel.text = "£\(roundedPrice)"
        
        storeNameLabel.text = product.shopName
        
        guard let productDistance = product.distance else {
            productDistanceLabel.text = "x km"
            return
        }
        
        let productDistanceInKm = productDistance / 1000
        
        let roundedDistance = String(format: "%.2f", productDistanceInKm)
        print("deadBeef HJ productDistanceInKm: \(productDistanceInKm)")
        print("deadBeef HJ roundedDistance: \(roundedDistance)")
        productDistanceLabel.text = "\(roundedDistance) km"
        
        print("deadBeef productLikers are: \(String(describing: product.likedBy))")
        print("deadBeef KK current uid in cell updateUI: \(String(describing: uid))")
        let productLikers = product.likedBy
        print("deadBeef KK checking liked state of \(String(describing: product.brand))")
        if productLikers != nil && uid != nil {
            if (productLikers?.contains(uid!))! {
                print("deadBeef KK changing likeButton image to liked of product: \(String(describing: product.brand))")
                currentState = .liked
            }
        }
    }
}
