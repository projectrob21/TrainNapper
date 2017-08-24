//
//  Napper.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/26/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import GoogleMaps

final class Napper: NSObject {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var destinations = [Station]()
    

    // Used for LocationAutorization
    weak var presentAlertDelegate: PresentAlertDelegate?
    
    // Used for testing distance to destination
    weak var distanceDelegate: GetDistanceDelegate?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
}

// MARK: Location Authorization and Setup
extension Napper: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        requestLocationAuthorization()
        
        //Energy efficiency
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = true
        
        locationManager.startUpdatingLocation()
    }
    
    func requestLocationAuthorization() {
//        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            print("authorization for location is NOT ALLOWED; hashValue: \(CLLocationManager.authorizationStatus().hashValue)")
            presentAlertDelegate?.presentAlert()
            
        } else {
            locationManager.startUpdatingLocation()
            print("authorized for location")
        }
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            // *** what if they selected a station, and then authorized use...? The destination array should be updated
            locationManager.requestLocation()
            print("napper re-initialized with location coordinate")
            
        } else {
            presentAlertDelegate?.presentAlert()
        }
    }
}

extension Napper {
    
    // Because of the implementation of RegionMonitoring, this delegate method is primarily used for testing
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        /*
         guard let coordinate = locations.last else { print("didUpdateLocations - error getting napper coordinate"); return }
         
         if destinations.count > 0 {
         
         let nextDestination = destinations[0]
         
         let distanceToStation =  nextDestination.coordinateCL.distance(from: coordinate)
         
         
         distanceDelegate?.distanceToStation(distance: distanceToStation)
         print("Napper is currently \(distanceToStation) meters from their next destination")
         
         }
         */
    }
}
