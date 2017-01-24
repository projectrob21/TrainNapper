//
//  LocationManager.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import GoogleMaps

final class MapViewModel: NSObject {
    
    let store = DataStore.sharedInstance
    var stations = [Station]()
    
    weak var filterDelegate: FilterViewDelegate?
    
    var markerWindowView: MarkerWindowView!
    var tappedMarker = GMSMarker()
    var proximityRadius = 6275.0
    
    var showFilter = false

    override init() {
        super.init()
        configure()
    }
    
    func configure() {
        store.populateAllStations()
        stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
        print("stations = \(stations.count)")
        
        addStationsToMap()
        
    }
    
    
    func addStationsToMap() {
        var markerArray = [GMSMarker]()
        for station in stations {
            
            let marker = GMSMarker(position: station.coordinate2D)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.title = station.name
            if station.branch == .LIRR {
                marker.icon = GMSMarker.markerImage(with: .lirrColor)
            } else if station.branch == .MetroNorth {
                marker.icon = GMSMarker.markerImage(with: .metroNorthColor)
            } else if station.branch == .NJTransit {
                marker.icon = GMSMarker.markerImage(with: .blue)
            }
            
            markerArray.append(marker)
            
        }
        print("ADD STATIONS MAP RUNNING IN VIEWMODEL WITH \(markerArray.count) MARKERS")
        filterDelegate?.addStationsToMap(stations: markerArray)
        
    }
    
    @objc func filterBranches(_ sender: UIButton) {
        guard let stationName = sender.titleLabel?.text else { print("could not retrieve station name"); return }
        
        if sender.backgroundColor == UIColor.filterButtonColor {
            
            switch stationName {
            case "LIRR":
                stations = stations.filter { $0.branch != .LIRR }
            case "Metro North":
                stations = stations.filter { $0.branch != .MetroNorth }
            case "NJ Transit":
                stations = stations.filter { $0.branch != .NJTransit }
            default: break
            }
            addStationsToMap()
            sender.backgroundColor = UIColor.gray
            
        } else {
            switch stationName {
            case "LIRR":
                stations = stations + store.lirrStationsArray
            case "Metro North":
                stations = stations + store.metroNorthStationsArray
            case "NJ Transit":
                stations = stations + store.njTransitStationsArray
            default: break
            }
            addStationsToMap()
            sender.backgroundColor = UIColor.filterButtonColor
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        print("stations count is \(stations.count)")
        print("search text: \(lowercasedSearchText)")
        if lowercasedSearchText != "" {
            stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
            stations = stations.filter { $0.name.lowercased().contains(lowercasedSearchText) }
            addStationsToMap()
        } else {
            stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
            addStationsToMap()
        }
    }
    
}



extension MapViewModel: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        markerWindowView = MarkerWindowView()
        markerWindowView.stationLabel.text = marker.title
        return markerWindowView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        // if station has not been selected
        //        addAlarm(marker)
        //        marker.icon = GMSMarker.markerImage(with: .blue)
        // else if station is currently selected
        // removeAlarm(marker)
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        /*
         if status == CLAuthorizationStatus.authorizedAlways {
         locationManager.startUpdatingLocation()
         guard let unwrappedLocation = locationManager.location else { print("error initializing user's location"); return }
         napper.coordinate = unwrappedLocation
         } else {
         locationManager.requestAlwaysAuthorization()
         }
         */
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
        napper.coordinate = locations.last
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
        print("Napper's current location is \(napperLocation)")
        
        // Napper's destinations always sorted by nearest
        if napper.destination.count > 1 {
            napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
            })
        }
        
        
        if napper.destination.count > 0 {
            print("Napper is currently \(napper.destination[0].coordinateCL.distance(from: napperLocation)) meters from their next destination")
            distanceLabel.text = "\(napper.destination[0].coordinateCL.distance(from: napperLocation))"
            let nextDestination = napper.destination[0]
            
            if napperLocation.distance(from: nextDestination.coordinateCL) < proximityRadius {
                
                // SOUND THE ALARM!!!!
                //                print("SENDING NOTIFICATION")
                //                let alert = UIAlertController(title: "WAKE UP!", message: "You are now arriving at your destination", preferredStyle: .alert)
                //                let action = UIAlertAction(title: "Thank you!", style: .cancel, handler: { (action) in
                //                    self.napper.destination.removeFirst()
                //                })
                //                alert.addAction(action)
                //                self.present(alert, animated: true, completion: nil)
                
                
                // Notification Center Alarm
                let region = CLCircularRegion(center: nextDestination.coordinate2D, radius: proximityRadius as CLLocationDistance, identifier: "Next Destination")
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                let content = UNMutableNotificationContent()
                
                content.title = NSString.localizedUserNotificationString(forKey: "this is the content title", arguments: nil)
                content.body = "this is the content body"
                content.sound = UNNotificationSound.default()
                
                let request = UNNotificationRequest(identifier: "Alarm for \(nextDestination.name)", content: content, trigger: trigger)
                
                appDelegate.center.add(request)
                
                
            }
        }
        */
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        /*
        print("DID ENTER THE REGION!!!!!!")
        
        let alert = UIAlertController(title: "WAKE UP!", message: "You are now arriving at your destination", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        */
    }

}
