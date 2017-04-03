//
//  MapView.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import GoogleMaps
import GoogleMobileAds
import AudioToolbox

class MapView: UIView {
    
    // MARK: Properties
    
    let store = DataStore.shared
    
    var camera: GMSCameraPosition!
    var stationsMap: GMSMapView!
    var markerArray = [GMSMarker]()
    
    var alarmWindowViewController: AlarmWindowViewController!

    
    weak var filterBranchesDelegate: FilterBranchesDelegate?
    weak var napperAlarmsDelegate: NapperAlarmsDelegate?
    
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        configure()
        constrain()
    }
    
    
    // MARK: View Configuration
    func configure() {
        
        camera = GMSCameraPosition.camera(withLatitude: 40.7485, longitude: -73.9854, zoom: 8)
        stationsMap = GMSMapView.map(withFrame: .zero, camera: camera)
        stationsMap.isMyLocationEnabled = true
        stationsMap.settings.myLocationButton = true
        stationsMap.mapType = kGMSTypeNormal
        stationsMap.delegate = self
        
        
    }
    
    // MARK: View Constraints
    func constrain() {
        
        addSubview(stationsMap)
        stationsMap.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
}

// MARK: Adds markers to map and filters

extension MapView: AddToMapDelegate {
    
    
    func addStationsToMap(stations: StationDictionary) {
        clusterManager.clearItems()
        
        for (_, station) in stations {
            
            let clusterStation = StationCluster(position: station.coordinate2D, name: station.name)
            
            if !station.isHidden {
                clusterManager.add(clusterStation)
            }
        }
        clusterManager.cluster()
    }
    
    func filterBranches(_ sender: UIButton) {
        guard let stationName = sender.titleLabel?.text else { print("could not retrieve station name"); return }
        
        var branch: Branch = .unknown
        var isHidden = false
        
        if sender.backgroundColor == UIColor.filterButtonColor {
            
            switch stationName {
            case "LIRR":
                branch = .LIRR; isHidden = true
            case "Metro North":
                branch = .MetroNorth; isHidden = true
            case "NJ Transit":
                branch = .NJTransit; isHidden = true
            default: break
            }
            sender.backgroundColor = UIColor.gray
        } else {
            switch stationName {
            case "LIRR":
                branch = .LIRR
            case "Metro North":
                branch = .MetroNorth
            case "NJ Transit":
                branch = .NJTransit
            default: break
            }
            sender.backgroundColor = UIColor.filterButtonColor
        }
        filterBranchesDelegate?.filterBranches(branch: branch, isHidden: isHidden)
    }
}

extension MapView: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
//        markerWindowView = MarkerWindowView()
//        markerWindowView.stationLabel.text = "PLEASE MAKE THIS WINDOW NICER"
//        return markerWindowView
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        /*
         guard let station = store.stationsDictionary[marker.snippet!] else { print("mapview - trouble unwrapping station"); return }
         
         
         if marker.icon != UIImage.alarmClock {
         napperAlarmsDelegate?.addAlarm(station: station)
         marker.icon = UIImage.alarmClock
         } else {
         napperAlarmsDelegate?.removeAlarm(station: station)
         
         switch station.branch {
         case .LIRR: marker.icon = UIImage.lirrIcon
         case .MetroNorth: marker.icon = UIImage.metroNorthIcon
         case .NJTransit: marker.icon = UIImage.njTransitIcon
         default: break
         }
         }
         */
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("LONG TOUCH AT COORDINATE \(coordinate)")
        // Vibrates once
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        let newMarker = GMSMarker(position: coordinate)
        newMarker.map = mapView
        
        let newAlarm = Alarm()
        
        newAlarm.id = "\(UUID())"
        
        try! store.realm.write {
            store.user.alarms.append(newAlarm)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        
        // TRUE if this delegate handled the tap event, which prevents the map from performing its default selection behavior, and FALSE if the map should continue with its default selection behavior.
        return true
    }
    
}

extension MapView {
    
    func presentAddUserController() {
        alarmWindowViewController = AlarmWindowViewController()
        alarmWindowViewController.parentVC = self
        view.addSubview(addUserViewController.view)
        alarmWindowViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alarmWindowViewController.didMove(toParentViewController: nil)
        view.layoutIfNeeded()
        
        print("PARENT = \(alarmWindowViewController.parent)")
        
        navigationItem.rightBarButtonItem?.title = "Dismiss"
        navigationItem.rightBarButtonItem?.action = #selector(dismissViewAddUSerController)
    }
    
    func dismissViewAddUSerController() {
        APIClient.getSpotifyUsersData(branch: "people", not: false, nameOrID: nil) { (jsonData) in
            self.users = []
            for response in jsonData {
                let newUser = User(herokuJSON: response)
                self.users.append(newUser)
            }
            OperationQueue.main.addOperation {
                print("number of users is \(self.users.count)")
                self.users = self.users.sorted(by: {
                    $0.0.id < $0.1.id
                })
                self.tableView.reloadData()
            }
        }
        
        navigationItem.rightBarButtonItem?.title = "Add User"
        navigationItem.rightBarButtonItem?.action = #selector(presentAddUserController)
        
        willMove(toParentViewController: nil)
        alarmWindowViewController.view.removeFromSuperview()
        alarmWindowViewController = nil
        
        
        
    }
    
}

extension MapView: GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        print("rendering")
        
        
        
        guard let stationData = marker.userData as? StationCluster else { print("error unwrapping station in willRenderMarker"); return }
        
        print("marker.userData = \(stationData.name)")
        
        guard let station = store.stationsDictionary[stationData.name] else { print("mapview - trouble unwrapping station"); return }
        print("station = \(station.name)")
        marker.snippet = station.name
        
        if !station.isHidden {
            switch station.branch {
            case .LIRR: marker.icon = UIImage.lirrIcon
            case .MetroNorth: marker.icon = UIImage.metroNorthIcon
            case .NJTransit: marker.icon = UIImage.njTransitIcon
            default: break
            }
            if station.isSelected {
                marker.icon = UIImage.alarmClock
            }
        }
        
        
    }
    
    
    
    //        func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
    //        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
    //                                                           zoom: stationsMap.camera.zoom + 1)
    //        let update = GMSCameraUpdate.setCamera(newCamera)
    //        stationsMap.moveCamera(update)
    //        return true
    //    }
}
