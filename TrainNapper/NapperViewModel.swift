//
//  NapperViewModel.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import GoogleMaps

final class NapperViewModel: NSObject {
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setupManager()
    }
    
    
}


// MARK: - Map Management
extension NapperViewModel: CLLocationManagerDelegate {
    
    func setupManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = true
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways{
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }

    }
    
}
