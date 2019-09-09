//
//  DetailNotificationVM.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

final class DetailNotificationVM: ListDiffable {
    
    let notification: String?
    
    init(notification: String?) {
        
        if notification == nil {
            self.notification = "Contact shop to check availability"
        } else {
            self.notification = "Contact shop to check availability. \nProduct code: \(notification!)"
        }
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "DetailNotificationVM" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DetailNotificationVM else {return false}
        
        return notification == object.notification
    }
    
}
