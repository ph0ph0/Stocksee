//
//  NetworkStatusIndicator.swift
//  stckchck
//
//  Created by Pho on 19/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class NetworkStatusIndicator: UIView {
    
    let label: UILabel = UILabel()
    
    typealias networkType = Reachability.Connection
    
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
        
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.alpha = 0
            weakSelf?.layer.cornerRadius = 7
            weakSelf?.layer.masksToBounds = true
            weakSelf?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            
            //setup label
            weakSelf?.label.textAlignment = .center
            weakSelf?.label.textColor = .white
            weakSelf?.addSubview((weakSelf?.label)!)
        }
    }
    
    func removeNetworkStatusIndicator() {
        self.alpha = 0.0
    }
    
    func showNoNetworkIndicator() {
        self.backgroundColor = .red
        label.text = "No Network Connection"
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7) {[unowned self] in
                self.alpha = 0.5
            }
        }
    }
    
    func showNetworkConnectedTo(networkType: networkType) {
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.label.text = "Connected to \(networkType)"
            self.backgroundColor = .green
            UIView.animate(withDuration: 1.0, animations: { [unowned self] in
                self.alpha = 0.5
            }) { (_) in
                UIView.animate(withDuration: 1.0, delay: 1.0, animations:{ [unowned self] in
                    self.alpha = 0.0
                })
            }
        }
    }
    
    func showFindingLocation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.main.async { [weak weakSelf = self] in
            self.backgroundColor = UIColor(red:0.11, green:0.47, blue:0.87, alpha:1.0)
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
            self.backgroundColor = UIColor(red:0.19, green:0.68, blue:0.14, alpha:1.0)
            UIView.animate(withDuration: 1.0, animations: { [unowned self] in
                self.alpha = 0.5
            }) { (_) in
                UIView.animate(withDuration: 1.0, delay: 1.0, animations:{ [unowned self] in
                    self.alpha = 0.0
                })
            }
        }
        
    }
    
    func removeLocationIndicator() {
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.alpha = 0.0
        }
    }
}
