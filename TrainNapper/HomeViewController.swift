//
//  ViewController.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import EventKit
import UserNotifications
import GoogleMaps
import GooglePlaces

class HomeViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    let store = DataStore.sharedInstance
    var stations = [Station]()
    var mapView: MapView!
    lazy var napper = Napper(coordinate: nil, destination: [])
    var markerWindowView: MarkerWindowView!
    var tappedMarker = GMSMarker()
    var locationManager = CLLocationManager()
    
    var proximityRadius = 875.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configure() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways{
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
        
        if appDelegate.eventStore == nil {
            appDelegate.eventStore = EKEventStore()
            appDelegate.eventStore?.requestAccess(to: EKEntityType.reminder, completion: { (granted, error) in
                if !granted {
                    print("Access to EventStore not granted")
                } else {
                    print("Access to EventStore granted")
                    
                }
            })
            
        }
        
        store.populateLIRRStationsFromJSON()
        stations = store.lirrStationsArray
        
        mapView = MapView()
        mapView.stationsMap.delegate = self
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        for station in stations {
            
            let marker = GMSMarker(position: station.coordinate2D)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.title = station.name
            
            //            marker.icon = GMSMarker.markerImage(with: .clear)
            //            marker.icon = #imageLiteral(resourceName: "lirr")
            //            marker.layer.backgroundColor = UIColor.blue.cgColor
            //            marker.layer.opacity = 50
            
            marker.map = mapView.stationsMap
        }
        
    }
    
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways {
            
            locationManager.startUpdatingLocation()
            print("LOCATION MANAGER = \(locationManager.location)")
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
        
        guard let myDestination = store.lirrStationsDictionary[sender.title!] else { print("error setting alarm"); return }
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
        guard let eventStore = appDelegate.eventStore else { print("error casting event store in didupdatelocation"); return }
        
        
        napper.destination.append(myDestination)
        print("Napper's destination(s): \(napper.destination)")
        if napper.destination.count > 1 {
            napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
            })
        }
        
        let nextDestination = napper.destination[0]
        
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
    
                let region = CLCircularRegion(center: nextDestination.coordinate2D, radius: proximityRadius as CLLocationDistance, identifier: "Next Destination")
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                let content = UNMutableNotificationContent()
                
                content.title = NSString.localizedUserNotificationString(forKey: "this is the content title", arguments: nil)
                content.body = "this is the content body"
                
                
                let request = UNNotificationRequest(identifier: "Alarm for \(nextDestination.name)", content: content, trigger: trigger)
                
                appDelegate.center.add(request)
                

            }
        }
        
        
        
    }
    
    
    
}

