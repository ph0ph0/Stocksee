//
//  DismissKeyboardVCExt.swift
//  stckchck
//
//  Created by Pho on 30/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTapOnVC() {
        
        let tapGestureRecogniser: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
