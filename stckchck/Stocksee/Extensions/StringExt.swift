//
//  StringExt.swift
//  stckchck
//
//  Created by Pho on 23/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation

extension String {
    // This is used to convert the facets from camel case to user readable words. 
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.characters.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
    }
}
