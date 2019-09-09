//
//  SearchFooter.swift
//  stckchck
//
//  Created by Pho on 26/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class SearchFooter: UIView {
    
    let label: UILabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    fileprivate func configureView() {
        
        self.backgroundColor = .black
        self.alpha = 0.0
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        //Configure Label
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = self.bounds
    }
    
    //MARK: Animation
    
    fileprivate func hideFooter() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7) {[unowned self] in
                self.alpha = 0.0
                print("deadBeef hid searchFooter, alpha: \(self.alpha)")
            }
        }
    }
    
    fileprivate func showFooter() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7) {[unowned self] in
                self.alpha = 0.5
                print("deadBeef showed searchFooter, alpha: \(self.alpha)")
            }
        }
    }
}

//MARK: Public API

extension SearchFooter {
    
    public func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    public func setFindingProducts() {
        label.text = "Finding products..."
        showFooter()
    }
    
    public func setIsFilteringToShow(filteredItemCount: Int) {
        if filteredItemCount == 0 {
            label.text = "No items match your query"
            showFooter()
        } else if filteredItemCount == 1 {
            label.text = "Found \(filteredItemCount) matching item"
            showFooter()
        } else if filteredItemCount > 1 {
            label.text = "Found \(filteredItemCount) matching Items"
            showFooter()
        }
    }
}
