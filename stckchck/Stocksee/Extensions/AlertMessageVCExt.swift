//
//  AlertMessageVCExt.swift
//  stckchck
//
//  Created by Pho on 30/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alertMessage(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func noResultsFoundAlert() {
        
        let title1 = "New products added every day!"
        let title2 = "Broaden your horizons..."
        let title3 = "GOOBAGABA"
        
        let message1 = "We are a growing company, and unfortunately, we couldn't find a product matching your search... yet. Please try again soon!"
        let message2 = "Pinch the screen to increase your search area! You may find what you're looking for further afield..."
        let message3 = "Got your attention. Pinch the screen to increase your search area. Shops further away may have your product in stock..."
        
        var titleToShow = String()
        var messageToShow = String()
        let randomNumber = arc4random_uniform(3) + 1
        
        if randomNumber == 1 {
            titleToShow = title1
            messageToShow = message1
        } else if randomNumber == 2 {
            titleToShow = title2
            messageToShow = message2
        } else if randomNumber == 3 {
            titleToShow = title3
            messageToShow = message3
        }
        
        let alert = UIAlertController(title: titleToShow, message: messageToShow, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
