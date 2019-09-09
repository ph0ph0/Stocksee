//
//  DetailNotificationCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailNotificationCell: UICollectionViewCell, ListBindable {
    
    var notification: String?
    
    @IBOutlet var notificationLabel: UILabel!
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailNotificationVM else {
            print("deadBeef IGLK failed to make dNotificationVM")
            return
        }
        notification = viewModel.notification
        notificationLabel.text = notification
    }
    
}
