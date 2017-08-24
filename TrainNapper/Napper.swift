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
    
    var coordinate: CLLocation?
    var destination = [Station]()
    var isUpdating = false
    
    let proximityRadius = 800.0
    var distanceToStation = 0.0
    
    var presentAlertDelegate: PresentAlertDelegate?

    
    override init() {
        super.init()
        setupLocationManager()
    }
    
}

// MARK: Location Management
extension Napper: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        //General setup
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //Energy efficiency
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = true
        
        locationManager.startUpdatingLocation()
    }
    
    func requestLocationAuthorization() {
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last
        
        guard let coordinate = coordinate else { print("didUpdateLocations - error getting napper coordinate"); return }
        print("didUpdateLocations - napper coordinate = \(coordinate)")
        
        
        if destination.count > 0 {
            
            let nextDestination = destination[0]
            distanceToStation = nextDestination.coordinateCL.distance(from: coordinate)
            
            // Used for testing movement and regions
//            distanceDelegate?.distanceToStation(distance: distanceToStation)
//            print("Napper is currently \(distanceToStation) meters from their next destination")
            
        }
    }
    
    /*
     func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
     
     print("DID ENTER THE REGION!!!!!!")
     
     }
     
     func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
     print("Location Manager PAUSED updates")
     }
     
     func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
     print("Location Manager RESUMED updates")
     }
     */
}
