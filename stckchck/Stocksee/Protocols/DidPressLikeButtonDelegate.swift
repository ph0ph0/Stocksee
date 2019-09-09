//
//  DidPressLikeButton.swift
//  stckchck
//
//  Created by Pho on 02/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

protocol DidPressLikeButtonDelegate: class {
    func didPressLikeButton(at cell: UITableViewCell)
}
