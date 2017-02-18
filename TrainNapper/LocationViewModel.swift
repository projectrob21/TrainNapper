//
//  LocationViewModel.swift
//  TrainNapper
//
//  Created by Robert Deans on 2/3/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import GoogleMaps

// Used for testing distance to destination
protocol PresentAlertDelegate: class {
    func presentAlert()
}
protocol GetDistanceDelegate: class {
    func distanceToStation(distance: Double)    
}

final class LocationViewModel: NSObject {
    
    var locationManager: CLLocationManager!
    var napper: Napper!
    
    let proximityRadius = 800.0
    var distanceToStation = 0.0
    
    weak var distanceDelegate: GetDistanceDelegate?

    var presentAlertDelegate: PresentAlertDelegate?

    convenience init(napper: Napper) {
        self.init()
        self.napper = napper
        setupLocationManager()
    }
    
}


// MARK: Location Management
extension LocationViewModel: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        //General setup
        locationManager = CLLocationManager()
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
            print("authorization for location is NOT ALWAYS; hashValue: \(CLLocationManager.authorizationStatus().hashValue)")
            presentAlertDelegate?.presentAlert()
            
        } else {
            locationManager.requestLocation()
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
        napper.coordinate = locations.last
        
        guard let napperLocation = napper.coordinate else { print("didUpdateLocations - error getting napper coordinate"); return }
        print("didUpdateLocations - napper coordinate = \(napperLocation)")
        
        
        if napper.destination.count > 0 {
            
            let nextDestination = napper.destination[0]
            distanceToStation = nextDestination.coordinateCL.distance(from: napperLocation)
            distanceDelegate?.distanceToStation(distance: distanceToStation)
            print("Napper is currently \(distanceToStation) meters from their next destination")
            
            if distanceToStation < proximityRadius {
                
                print("SENDING NOTIFICATION")
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("DID ENTER THE REGION!!!!!!")
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Location Manager PAUSED updates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Location Manager RESUMED updates")
    }
    
}

extension LocationViewModel: RegionsToMonitorDelegate {
    
    func addRegionToMonitor(region: CLCircularRegion) {
        locationManager.startMonitoring(for: region)

        print("MONITORED REGIONS = \(locationManager.monitoredRegions)")
    }

    func removeRegionToMonitor(region: CLCircularRegion) {
        locationManager.stopMonitoring(for: region)
        

        print("MONITORED REGIONS = \(locationManager.monitoredRegions)")
    }

    
}

protocol RegionsToMonitorDelegate {
    
    func addRegionToMonitor(region: CLCircularRegion)
    
    func removeRegionToMonitor(region: CLCircularRegion)

    
}

