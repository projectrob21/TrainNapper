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

/*
private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    
    if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways {
        
        locationManager.startUpdatingLocation()
        guard let unwrappedLocation = locationManager.location else { print("error initializing user's location"); return }
        napper = Napper(coordinate: unwrappedLocation, destination: [])
        
    }
}

// MARK: GMSMapViewDelegate

func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    
    markerWindowView = MarkerWindowView()
    markerWindowView.stationLabel.text = marker.title
    return markerWindowView
    
}

func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    // if station has not been selected
    addAlarm(marker)
    marker.icon = GMSMarker.markerImage(with: .blue)
    // else if station is currently selected
    // removeAlarm(marker)
}


func addAlarm(_ sender: GMSMarker) {
    
    guard let myDestination = store.stationsDictionary[sender.title!] else { print("error setting alarm"); return }
    guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
    
    // Adds station to napper's destination array
    napper.destination.append(myDestination)
    print("Napper's destination(s): \(napper.destination)")
    
    // Sorts destination array by proximity
    if napper.destination.count > 1 {
        napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
        })
    }
    
    /*
     
     // Creates an alarm using Region Monitoring
     for destination in napper.destination {
     let region = CLCircularRegion(center: destination.coordinate2D, radius: proximityRadius, identifier: destination.name)
     region.notifyOnEntry = true
     region.notifyOnExit = false
     locationManager.startMonitoring(for: region)
     print("Monitored Regions count: \(locationManager.monitoredRegions.count)")
     
     }
     
     
     // Creates an alarm using EKEvents
     
     let nextDestination = napper.destination[0]
     guard let eventStore = appDelegate.eventStore else { print("error casting event store in didupdatelocation"); return }
     
     let destinationReminder = EKReminder(eventStore: eventStore)
     destinationReminder.title = nextDestination.name
     destinationReminder.calendar = eventStore.defaultCalendarForNewReminders()
     
     
     let stationLocation = EKStructuredLocation(title: "Alarm will sound at \(nextDestination.name)")
     stationLocation.geoLocation = nextDestination.coordinateCL
     stationLocation.radius = proximityRadius
     
     let alarm = EKAlarm()
     alarm.structuredLocation = stationLocation
     alarm.proximity = EKAlarmProximity.enter
     
     destinationReminder.addAlarm(alarm)
     
     do {
     try eventStore.save(destinationReminder, commit: true)
     print("EVENT WAS ADDED TO STORE with name \(destinationReminder.title)\nCoordinates \(destinationReminder.alarms![0].structuredLocation!.geoLocation!)\nWithin \(destinationReminder.alarms![0].structuredLocation!.radius) meters")
     } catch let error {
     print("Reminder failed with error \(error.localizedDescription)")
     }
     
     */
    
    
}

func removeAlarm(_ sender: GMSMarker) {
    guard let myDestination = store.stationsDictionary[sender.title!] else { print("error removing alarm destination"); return }
    
    for (index, destination) in napper.destination.enumerated() {
        if destination.name == myDestination.name {
            napper.destination.remove(at: index)
        }
    }
    
}

func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    
    print("DID ENTER THE REGION!!!!!!")
    
    let alert = UIAlertController(title: "WAKE UP!", message: "You are now arriving at your destination", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    self.present(alert, animated: true, completion: nil)
    
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    napper.coordinate = locations.last
    print("Napper's current location is \(napper.coordinate!)")
    guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
    
    if napper.destination.count > 1 {
        napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
        })
    }
    
    if napper.destination.count > 0 {
        print("Napper is currently \(napper.destination[0].coordinateCL.distance(from: napperLocation)) meters from their next destination")
        
        let nextDestination = napper.destination[0]
        
        
        if napperLocation.distance(from: nextDestination.coordinateCL) < proximityRadius {
            //SOUND THE ALARM!!!!
            print("SENDING NOTIFICATION")
            
            let alert = UIAlertController(title: "WAKE UP!", message: "You are now arriving at your destination", preferredStyle: .alert)
            let action = UIAlertAction(title: "Thank you!", style: .cancel, handler: { (action) in
                self.napper.destination.removeFirst()
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            
            /*
             let region = CLCircularRegion(center: nextDestination.coordinate2D, radius: proximityRadius as CLLocationDistance, identifier: "Next Destination")
             region.notifyOnEntry = true
             region.notifyOnExit = false
             
             let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
             let content = UNMutableNotificationContent()
             
             content.title = NSString.localizedUserNotificationString(forKey: "this is the content title", arguments: nil)
             content.body = "this is the content body"
             
             
             let request = UNNotificationRequest(identifier: "Alarm for \(nextDestination.name)", content: content, trigger: trigger)
             
             appDelegate.center.add(request)
             
             */
            
        }
    }
    
}
*/
