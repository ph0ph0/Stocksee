//
//  FindingLocationIndicator.swift
//  stckchck
//
//  Created by Pho on 20/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class FindingLocationIndicator: UIView {
    
    let label: UILabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = self.bounds
    }
    
    fileprivate func configureView() {
        
        self.alpha = 0
        
        //setup label
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
    }
    
    func removeLocationIndicator() {
        self.alpha = 0.0
    }
    
    func showNoNetworkIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.backgroundColor = .red
            weakSelf?.label.text = "No Network Connection"
            UIView.animate(withDuration: 0.7) {[unowned self] in
                self.alpha = 0.5
            }
        }
        
    }
    
    func showFindingLocation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.backgroundColor = UIColor(red:0.11, green:0.47, blue:0.87, alpha:1.0)
            weakSelf?.label.text = "Finding Location..."
            UIView.animate(withDuration: 0.7) {[unowned self] in
                self.alpha = 0.5
            }
        }
       
    }
    
    func showFoundLocation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.label.text = "Found Location"
            weakSelf?.backgroundColor = .green
            UIView.animate(withDuration: 1.0, animations: { [unowned self] in
                self.alpha = 0.5
            }) { (_) in
                UIView.animate(withDuration: 1.0, delay: 1.0, animations:{ [unowned self] in
                    self.alpha = 0.0
                })
            }
        }
        
    }
}
