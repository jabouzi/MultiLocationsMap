//
//  EventAnnotation.swift
//  AllConnectRoute
//
//  Created by Isuru Nanayakkara on 7/31/15.
//  Copyright (c) 2015 BitInvent. All rights reserved.
//

import MapKit
import UIKit

class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
