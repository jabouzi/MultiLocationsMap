//
//  Event.swift
//  AllConnectRoute
//
//  Created by Isuru Nanayakkara on 7/31/15.
//  Copyright (c) 2015 BitInvent. All rights reserved.
//

import UIKit
import MapKit

class Event: NSObject {
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    override init() {
        super.init()
    }
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
