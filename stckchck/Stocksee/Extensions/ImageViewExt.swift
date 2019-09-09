//
//  ImageViewExt.swift
//  stckchck
//
//  Created by Pho on 21/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class designableImageView: UIImageView {}

//This gives the imageViews a grey, rounded border
extension designableImageView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColour: UIColor? {
        get {
            if let colour = layer.borderColor {
                return UIColor(cgColor: colour)
            }
            return nil
        }
        set {
            if let colour = newValue {
                layer.borderColor = colour.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var maskToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    
    
    
}












