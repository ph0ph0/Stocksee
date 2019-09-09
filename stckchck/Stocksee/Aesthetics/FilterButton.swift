//
//  FilterButton.swift
//  stckchck
//
//  Created by Pho on 24/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import UIKit

enum FilterButtonState {
    case facetsApplied
    case noFacets
}

class FilterButton: UIButton {
    
    var currentFilterString: String?
    
    private var current: FilterButtonState = FilterButtonState.noFacets
    
    func getCurrentState() -> FilterButtonState {
        return current
    }
    
    public func changeState(accordingTo filterString: String) {
        print("deadBeef XS filterString filterButton \(filterString)")
        switch current {
        case .noFacets:
            if filterString != "" {
                print("deadBeef applying facets")
                current = .facetsApplied
                showOrange()
            }
        case .facetsApplied:
            if filterString == "" {
                print("deadBeef removing facets")
                current = .noFacets
                showBlue()
            }
        }
    }
    
    private func showBlue() {
        UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve, animations: {
            self.setBackgroundImage(UIImage(named: "RefineButtonFade1"), for: .normal)
        }, completion: nil)
    }
    
    private func showOrange() {
        UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve, animations: {
            self.setBackgroundImage(UIImage(named: "ClearFiltersButton"), for: .normal)
        }, completion: nil)
    }
}
