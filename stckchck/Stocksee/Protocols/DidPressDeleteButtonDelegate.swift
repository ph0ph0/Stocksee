//
//  DidPressDeleteButtonDelegate.swift
//  stckchck
//
//  Created by Pho on 03/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

protocol DidPressDeleteButtonDelegate: class {
    func deleteProductViaDeleteButton(cell: SavedProductCell)
}
