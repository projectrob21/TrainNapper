//
//  NapperViewModel.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import GoogleMaps
import UserNotifications

protocol GetDistanceDelegate: class {
    func distanceToStation(distance: Double)
    
}

final class NapperViewModel: NSObject {
    
    
    let locationManager = CLLocationManager()
    var napper: Napper!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let proximityRadius = 1785.0
    var distanceToStation = 0.0
    var distanceDelegate: GetDistanceDelegate?
    
    override init() {
        super.init()
        setupLocationManager()
        
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("UNUserNotification request granted")
            } else {
                print("UNUserNotification request NOT granted")
            }
        }
    }
    
}


// MARK: Location Management
extension NapperViewModel: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = true
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways{
            locationManager.startUpdatingLocation()
            napper = Napper(coordinate: locationManager.location, destination: [])
            print("napper initialized with coordinate")
        } else {
            locationManager.requestAlwaysAuthorization()
            napper = Napper(coordinate: nil, destination: [])
            print("napper coordinate is nil")
        }
        
    }

    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedAlways {
            // *** what if they selected a station, and then authorized use...? The destination array should be updated
            locationManager.startUpdatingLocation()
            napper = Napper(coordinate: locationManager.location, destination: [])
            print("napper re-initialized with location coordinate")
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        let triggerTime = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "This is the locationManager", arguments: nil)
        content.body = "You are now entering the region!"
        content.sound = UNNotificationSound.default()
        
        
        let request = UNNotificationRequest(identifier: "RegionManagerAlarm", content: content, trigger: triggerTime)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        print("DID ENTER THE REGION!!!!!!")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        napper.coordinate = locations.last
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
        
        if napper.destination.count > 1 {
            napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
            })
        }
        
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
    
    
}

// MARK: Tableview Delegate
extension NapperViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return napper.destination.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        let station = napper.destination[indexPath.row].name
        
        cell.textLabel?.text = station
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let destination = self.napper.destination[indexPath.row].name
            
            let center = UNUserNotificationCenter.current()
            center.removeDeliveredNotifications(withIdentifiers: ["Alarm for \(destination)"])
            
            self.napper.destination.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
        return [delete]
    }
    
}


// MARK: Alarms Delegate
extension NapperViewModel: NapperAlarmsDelegate, UNUserNotificationCenterDelegate {
    
    func addAlarm(station: Station) {
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
        
        napper.destination.append(station)
        
        // Sorts destination array by proximity
        if napper.destination.count > 1 {
            napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
            })
        }
        
        // Create alarm through:
        //      - region monitoring / push notification
        //      - EKEvents
        //      - locationManager's didEnterRegion
        //      - locationManager's didUpdateLocation
        
        // Send by region maping

        let region = CLCircularRegion(center: station.coordinate2D, radius: proximityRadius, identifier: "identifier")
        region.notifyOnExit = false
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
        
        let triggerTime = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let triggerRegion = UNLocationNotificationTrigger(region: region, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Time to wake up!", arguments: nil)
        content.body = "You are now arriving at \(station.name)"
        content.sound = UNNotificationSound.default()
        
        
        let request = UNNotificationRequest(identifier: "Alarm for \(station.name)", content: content, trigger: triggerTime)

        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        center.getPendingNotificationRequests { (requests) in
            print("added- there are now \(requests.count) requests in pending notifications")
        }

    }
    
    
    
    func removeAlarm(station: Station) {

        for (index, destination) in napper.destination.enumerated() {
            if destination.name == station.name {
                napper.destination.remove(at: index)
            }
        }
    
        // Also need to remove notification
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["Alarm for \(station.name)"])
        
        center.getPendingNotificationRequests { (requests) in
            print("removed- there are now \(requests.count) requests in pending notifications")
        }

    }
    
    // Used to present notifications while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }

}

/*
func addEKAlarm(_ sender: GMSMarker) {
 
    // Creates an alarm using EKEvents
    
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
    
}
*/
