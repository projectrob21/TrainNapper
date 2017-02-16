//
//  Napper.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/26/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import GoogleMaps

final class Napper {
    
    var coordinate: CLLocation?
    var destination = [Station]()
    var isUpdating = false
    
    init(coordinate: CLLocation?) {
        self.coordinate = coordinate
    }
    
}
