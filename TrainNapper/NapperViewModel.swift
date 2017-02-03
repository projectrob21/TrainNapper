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

protocol PresentAlertDelegate: class {
    func presentAlert()
}

final class NapperViewModel: NSObject {
    
    var locationManager: CLLocationManager!
    var napper: Napper!
    let center = UNUserNotificationCenter.current()


    let proximityRadius = 1785.0
    var distanceToStation = 0.0
    
    weak var distanceDelegate: GetDistanceDelegate?
    weak var changeColorDelegate: ChangeMarkerColorDelegate?
    var presentAlertDelegate: PresentAlertDelegate?
    
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
        
        napper = Napper(coordinate: nil, destination: [])
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = true

    }
    
    func requestLocationAuthorization() {
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            print("authorization for location is NOT ALWAYS; hashValue: \(CLLocationManager.authorizationStatus().hashValue)")
            presentAlertDelegate?.presentAlert()
            
        } else {
            locationManager.requestLocation()
            print("authorized for location")
        }
    }

    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedAlways {
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
    
}


// MARK: Alarms Delegate
extension NapperViewModel: NapperAlarmsDelegate, UNUserNotificationCenterDelegate {
    
    func addAlarm(station: Station) {
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate - addAlarm"); return }
        
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
        
        let triggerTime = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let triggerRegion = UNLocationNotificationTrigger(region: region, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Time to wake up!", arguments: nil)
        content.body = "You are now arriving at \(station.name)"
        content.sound = UNNotificationSound.default()
        
        
        let request = UNNotificationRequest(identifier: "Alarm for \(station.name)", content: content, trigger: triggerTime)

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
    
        center.removePendingNotificationRequests(withIdentifiers: ["Alarm for \(station.name)"])
        
        center.getPendingNotificationRequests { (requests) in
            print("removed- there are now \(requests.count) requests in pending notifications")
        }

    }
    
    // Used to present notifications while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        center.getDeliveredNotifications { (requests) in
            print("get delivered called in willPResent")
            for request in requests {
                let stationName = request.request.identifier
                print("presented notification for \(stationName)")
                self.changeColorDelegate?.changeMarkerColor(for: stationName)
            }
        }
        
        completionHandler([.alert, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        center.getDeliveredNotifications { (requests) in
            print("get delivered called in didReceive")

            for request in requests {
                let stationName = request.request.identifier
                self.changeColorDelegate?.changeMarkerColor(for: stationName)
            }
        }
        completionHandler()
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
            
            self.center.removeDeliveredNotifications(withIdentifiers: [destination])
            
            self.napper.destination.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        return [delete]
    }
    
}
