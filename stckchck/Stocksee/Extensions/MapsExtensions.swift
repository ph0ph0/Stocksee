//
//  MapsExtensions.swift
//  stckchck
//
//  Created by Pho on 04/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)
        
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        
        return coords
    }
}

