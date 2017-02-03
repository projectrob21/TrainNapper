//
//  Stations.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import GoogleMaps

class Station {
    let id: Int
    let name: String
    let branch: Branch
    var isSelected = false
    var isHidden = false
    let latitude: Double
    let longitude: Double
    var coordinate2D: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
        }
    }
    var coordinateCL: CLLocation {
        get {
            return CLLocation(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
        }
    }
    
    init(jsonData: [String : Any]) {
        self.name = jsonData["stop_name"] as! String
        
        let latSting = jsonData["stop_lat"] as! String
        self.latitude = Double(latSting)!
        
        let lonString = jsonData["stop_lon"] as! String
        self.longitude = Double(lonString)!
        
        let idString = jsonData["stop_id"] as! String
        self.id = Int(idString)!
        
        let branch = jsonData["branch"] as! String
        
        switch branch {
            case "LIRR" : self.branch = .LIRR;
            case "MetroNorth" : self.branch = .MetroNorth;
            case "NJTransit" : self.branch = .NJTransit;
            default: self.branch = .unknown
        }
    }
    
}

enum Branch {
    case LIRR, MetroNorth, NJTransit, unknown
}
