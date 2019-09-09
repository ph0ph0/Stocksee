//
//  EmailCheckVCExt.swift
//  stckchck
//
//  Created by Pho on 30/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
