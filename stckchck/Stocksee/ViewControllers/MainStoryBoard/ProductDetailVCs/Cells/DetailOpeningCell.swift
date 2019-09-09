//
//  DetailOpeningCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailOpeningCell: UICollectionViewCell, ListBindable {
    
    var openingTimes: String?
    
    @IBOutlet weak var openingTimesTextView: UITextView!
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailOpeningVM else {
            print("deadBeef IGLK failed to make dOpeningVM")
            return
        }
        
        openingTimes = viewModel.openingTimes
        
        guard let openingTimes = openingTimes else {
            print("deadBeef no opening times")
            return
        }
        
        let formattedOpeningTimes = openingTimes.replacingOccurrences(of: ", ", with: "\r\n")
        
        openingTimesTextView.text = formattedOpeningTimes
        
    }
    
}
