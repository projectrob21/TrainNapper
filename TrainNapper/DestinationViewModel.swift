//
//  DestinationViewModel.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import GoogleMaps
import UserNotifications


protocol NapperAlarmsDelegate: class {
    func addAlarm(station: Station)
    func removeAlarm(station: Station)
}

final class DestinationViewModel: NSObject {
    
    let store = DataStore.sharedInstance
    
    var napper: Napper!
    let center = UNUserNotificationCenter.current()


    let proximityRadius = 1785.0
    var distanceToStation = 0.0
    
//    weak var distanceDelegate: GetDistanceDelegate?

    var addRegionToMonitorDelegate: AddRegionToMonitor?
    
    
    convenience init(napper: Napper) {
        self.init()
        self.napper = napper

        
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


// MARK: Alarms Delegate
extension DestinationViewModel: NapperAlarmsDelegate, UNUserNotificationCenterDelegate {
    
    func addAlarm(station: Station) {

        station.isSelected = true
        napper.destination.append(station)

        
        /*
        // Sorts destination array by proximity
        
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate - addAlarm"); return }
        
        if napper.destination.count > 1 {
            napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
            })
        }
        
        // ^^ may not be necessary depending on region mapping
        
        */
        
        // Send by region maping

        let region = CLCircularRegion(center: station.coordinate2D, radius: proximityRadius, identifier: "identifier")
        region.notifyOnExit = false
        region.notifyOnEntry = true
        
        addRegionToMonitorDelegate?.addRegionToMonitor(region: region)
        
        let triggerTime = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let triggerRegion = UNLocationNotificationTrigger(region: region, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Time to wake up!", arguments: nil)
        content.body = "You are now arriving at \(station.name)"
        content.sound = UNNotificationSound.default()
        
        
        let request = UNNotificationRequest(identifier: station.name, content: content, trigger: triggerRegion)

        center.add(request)
        
        center.getPendingNotificationRequests { (requests) in
            print("added- there are now \(requests.count) requests in pending notifications")
            
 
        }
        
    }

    
    func removeAlarm(station: Station) {
        station.isSelected = false
        for (index, destination) in napper.destination.enumerated() {
            if destination.name == station.name {
                napper.destination.remove(at: index)
            }
        }
        
        center.removePendingNotificationRequests(withIdentifiers: [station.name])
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
                guard let station = self.store.stationsDictionary[stationName] else { print("no such station in willPresent"); return }
                self.removeAlarm(station: station)
            }
        }
        
        completionHandler([.alert, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        center.getDeliveredNotifications { (requests) in
            print("get delivered called in didReceive")

            for request in requests {
                let stationName = request.request.identifier
                guard let station = self.store.stationsDictionary[stationName] else { print("no such station in willPresent"); return }
                self.removeAlarm(station: station)
            }
        }
        completionHandler()
    }

}

