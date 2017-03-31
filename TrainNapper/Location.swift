//
//  Location.swift
//  TrainNapper
//
//  Created by Robert Deans on 3/31/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import RealmSwift

final class Location: Object {
    
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    var clLocation: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    convenience init(clLocation: CLLocation) {
        self.init()
        self.latitude = clLocation.coordinate.latitude
        self.longitude = clLocation.coordinate.longitude
    }
    
    
}
