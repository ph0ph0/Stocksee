//
//  UIButtonSpinnerExt.swift
//  stckchck
//
//  Created by Pho on 10/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class LoadableButton: UIButton {
    
    var activityIndicator: UIActivityIndicatorView!
    var activityIndicatorColour: UIColor?
    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = activityIndicatorColour
        return activityIndicator
    }
    
    func removeActivityIndicator() {
        self.activityIndicator.removeFromSuperview()
    }
    
    func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}

class LoadableCellButton: LoadableButton {
    
    func showLoading() {
        self.setImage(UIImage(named: "LoadingButton"), for: .normal)
        self.setTitle("", for: .normal)
        self.activityIndicatorColour = .lightGray
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        if (activityIndicator != nil) {
            activityIndicator.stopAnimating()
            removeActivityIndicator()
        }
    }
    
    func hideLoadingShowImage() {
        if (activityIndicator != nil) {
            activityIndicator.stopAnimating()
            removeActivityIndicator()
            self.setImage(UIImage(named: "DismissCross"), for: .normal)
        }
    }
}

class LoadableSubmitButton: LoadableButton {
    
    var originalButtonText: String?
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.activityIndicatorColour = .white
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        if (activityIndicator != nil) {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.setTitle(originalButtonText, for: .normal)
            activityIndicator.stopAnimating()
            removeActivityIndicator()
        }
    }
    
}
