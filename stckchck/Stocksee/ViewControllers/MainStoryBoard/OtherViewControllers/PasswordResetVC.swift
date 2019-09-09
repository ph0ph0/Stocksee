//
//  PasswordResetVC.swift
//  stckchck
//
//  Created by Pho on 21/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class PasswordResetVC: UIViewController {
    
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var resetButtonOutlet: LoadableSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    @IBAction func resetButton(_ sender: Any) {
        
        print("deadBeef prVC resetButton pressed")
        
        resetButtonOutlet.showLoading()
        
        if isValidEmail(emailAddressTextField.text!) == false {
            resetButtonOutlet!.hideLoading()
            alertMessage("Attention", message: "Please enter a valid email address")
            return
        }
        
        if emailAddressTextField.text == "" {
            resetButtonOutlet!.hideLoading()
            alertMessage("Attention!", message: "Please ensure that you have entered your email address")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: emailAddressTextField.text!) { [weak weakSelf = self] (error) in
            if error == nil {
                weakSelf?.alertMessage("Successfully sent password reset email", message: "Please restart the stckchck app and check your inbox to change your password")
            } else if error != nil {
                
                guard let error = AuthErrorCode(rawValue: (error?._code)!) else {
                    return
                }
                
                fireErrorHandle(code: error)
                
                weakSelf?.resetButtonOutlet!.hideLoading()
                
                switch error {
                case .userDisabled:
                    weakSelf?.alertMessage("Failed to log user in", message: "User currently disabled")
                case .emailAlreadyInUse:
                    weakSelf?.alertMessage("Email already in use", message: "Please try a different email address")
                case .wrongPassword:
                    weakSelf?.alertMessage("Wrong password", message: "Please try another password")
                case .userNotFound:
                    weakSelf?.alertMessage("User not found", message: "Please try different login credentials")
                case .networkError:
                    weakSelf?.alertMessage("Network error", message: "Please try again with a better network connection")
                default:
                    weakSelf?.alertMessage("Error", message: "Please try logging in again")
                }
            }
        }
        
    }
    
    
    private func setupUI() {
        passwordTitle.font = UIFont(name: "AvenirNext-Regular", size: 38)
        
        let textFieldAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-UltraLight", size: 18)!
        ]
        
        emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: textFieldAttributes)
        emailAddressTextField.font = UIFont(name: "AvenirNext-Regular", size: 18)
        
        resetButtonOutlet!.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
    }
    
}
