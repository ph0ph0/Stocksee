//
//  ActivitySpinner.swift
//  stckchck
//
//  Created by Pho on 24/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import UIKit

class ActivitySpinner {
    
    func spin(_ view: UIView, startAnimate: Bool? = true) {
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .white
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        activityIndicator.tag = 19198123
        
        if startAnimate! {
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
        } else {
            for subview in view.subviews {
                if subview.tag == 19198123 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        
    }
    
}
