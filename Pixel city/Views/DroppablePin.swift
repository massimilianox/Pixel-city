//
//  DroppablePin.swift
//  Pixel city
//
//  Created by Massimiliano Abeli on 18/08/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    
//    When you mark a member declaration with the dynamic modifier,
//    access to that member is always dynamically dispatched using the Objective-C runtime.
//    Access to that member is never inlined or devirtualized by the compiler.
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
}
