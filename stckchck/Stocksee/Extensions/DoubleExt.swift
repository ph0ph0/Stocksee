//
//  DoubleExt.swift
//  stckchck
//
//  Created by Pho on 24/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation

extension Double {
    
    func roundDoubleToString() -> String {
        let roundedString = NSString(format: "%.2f", self)
        return roundedString as String
    }
    
}
