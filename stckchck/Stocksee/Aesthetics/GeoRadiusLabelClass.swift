//
//  geoRadiusLabel.swift
//  stckchck
//
//  Created by Pho on 24/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class GeoRadiusLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureView() {
        self.frame = CGRect(x: UIScreen.main.bounds.midX - 90, y: (UIScreen.main.bounds.midY - 90) - 60, width: 180, height: 180)
        self.backgroundColor = .black
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        self.alpha = 0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
    //MARK: Animation
    
    func displayGeoRadiusLabel() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.alpha = 0.7
            }
        }
    }
    
    func removeGeoRadiusLabel() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                self.alpha = 0
            }) { (success) in
                if success {
                    self.removeFromSuperview()
                    print("deadBeef removed from superview")
                }
            }
        }
    }
}










