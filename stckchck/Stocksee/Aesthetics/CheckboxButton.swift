//
//  CheckboxButton.swift
//  stckchck
//
//  Created by Pho on 01/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class CheckboxButton: UIButton {
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    enum TickState {
        case dormant
        case ticked
        case highlighted
    }
    
    var current: TickState = .dormant {
        didSet {
            switch current {
            case .ticked:
                self.setImage(UIImage(named:"SelectedCheckBox"), for: .normal)
            case .highlighted:
                self.setImage(UIImage(named:"ErrorCheckBox"), for: .normal)
            case .dormant:
                self.setImage(UIImage(named:"EmptyCheckBox"), for: .normal)
            }
        }
    }
    
    func changeState() {
        switch current {
        case .dormant:
            current = .ticked
        case .ticked:
            current = .dormant
        case .highlighted:
            current = .ticked
        }
    }
    
    func configureView() {
        self.setImage(UIImage(named: "EmptyCheckBox"), for: .normal)
    }
}
