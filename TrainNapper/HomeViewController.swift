//
//  ViewController.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import SnapKit
import EventKit
import UserNotifications
import GoogleMaps
import GooglePlaces
import GoogleMobileAds

class HomeViewController: UIViewController {
    
    var distanceLabel = UILabel()

    
    let store = DataStore.sharedInstance
    var napper: Napper!
    var stations = [Station]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var mapView = MapView()
    var markerWindowView: MarkerWindowView!
    var tappedMarker = GMSMarker()
    var locationManager = CLLocationManager()
    var proximityRadius = 6275.0
    
    lazy var filterView = FilterView()
    var showFilter = false
    lazy var searchBar = UISearchBar()
    var showSearch = false
    
    lazy var alarmsListView = AlarmsListView()
    var showAlarms = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        constrain()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Initial Setup
    func configure() {
        // Sets up LocationManager
        locationManager = CLLocationManager()
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
        
        // Populates stations and adds to map
        store.populateAllStations()
        stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
        
        mapView.stationsMap.delegate = self
        addStationsToMap()
        
        // Initializes Napper with temporary station in destinations array
        guard let unwrappedLocation = locationManager.location else { print("error initializing user's location in configure()"); return }
        napper = Napper(coordinate: unwrappedLocation, destination: [store.lirrStationsArray[0]])
        

        // Initializes advertising banner
        let banner = mapView.advertisingView
        banner?.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner?.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        banner?.load(request)
        
        // Sets up navigationBar
        navigationItem.title = "TrainNapper"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Alarms", style: .plain, target: self, action: #selector(showAlarmsView))
        
        // Sets up the FilterView
        filterView.searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        let stationFilterButtons = [filterView.lirrButton, filterView.metroNorthButton, filterView.njTransitButton]
        for stationButton in stationFilterButtons {
            stationButton.addTarget(self, action: #selector(showHideBranches(_:)), for: .touchUpInside)
        }
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Destination"
        searchBar.delegate = self
        searchBar.endEditing(true)
        
        // Sets up TableView
        alarmsListView.alarmsTableView.delegate = self
        alarmsListView.alarmsTableView.dataSource = self
        alarmsListView.alarmsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlarmCell")
        alarmsListView.isHidden = true
        
        
        // Event store... ?
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
        
//        let color2 = UIColor(red: 141/255.0, green: 191/255.9, blue: 103/255.0, alpha: 1.0)        
//        let backgroundGradient = CALayer.makeGradient(firstColor: UIColor.lirrColor, secondColor: color2)
//        backgroundGradient.frame = view.frame
//        self.view.layer.insertSublayer(backgroundGradient, at: 0)
        
        
        
    }
    
    func constrain() {
        
        view.addSubview(alarmsListView)
        alarmsListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        mapView.addSubview(filterView)
        filterView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(mapView.snp.top).offset(-132)
            $0.height.equalTo(44)
            
        }
        
        filterView.searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mapView.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-50)
            $0.leading.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(8)
            $0.width.equalToSuperview()
        }
        distanceLabel.backgroundColor = UIColor.white
        distanceLabel.textColor = UIColor.black
        distanceLabel.textAlignment = .center
        
        
        let filterbackgroundGradient = CALayer.makeGradient(firstColor: UIColor.njTransitColor, secondColor: UIColor.metroNorthColor)
        filterbackgroundGradient.frame = mapView.bounds
        mapView.layer.insertSublayer(filterbackgroundGradient, at: 0)
        viewDidLayoutSubviews()
        
    }
    
    func addStationsToMap() {
        
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
            
            marker.map = mapView.stationsMap
            
        }
    }
    
    // MARK: Filter Buttons
    func toggleFilterView() {
        showFilter = !showFilter
        view.layoutIfNeeded()
        if showFilter {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.filterView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalToSuperview()
                    $0.height.equalTo(50)
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.filterView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.bottom.equalTo(self.mapView.snp.top).offset(-132)
                    $0.height.equalTo(64)
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func showHideBranches(_ sender: UIButton) {
        guard let stationName = sender.titleLabel?.text else { print("could not retrieve station name"); return }
        
        if sender.backgroundColor == UIColor.filterButtonColor {
            mapView.stationsMap.clear()
            
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
    
}

extension HomeViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    
    // MARK: Search
    func searchButtonTapped() {
        showSearch = !showSearch
        
        if showSearch {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                
                self.filterView.searchView.snp.remakeConstraints {
                    $0.top.bottom.trailing.equalToSuperview()
                    $0.leading.equalTo(self.filterView.searchButton.snp.trailing)
                }
                
                self.searchBar.snp.remakeConstraints {
                    $0.edges.equalToSuperview()
                }
                
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                
                self.filterView.searchView.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.trailing.leading.equalTo(self.filterView.searchButton.snp.trailing)
                }
                self.searchBar.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.trailing.leading.equalTo(self.filterView.searchButton.snp.trailing)
                }
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    // MUST TAKE INTO ACCOUNT THE FILTERSTATIONS FUNCTION
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        print("stations count is \(stations.count)")
        print("search text: \(lowercasedSearchText)")
        if lowercasedSearchText != "" {
            stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
            stations = stations.filter { $0.name.lowercased().contains(lowercasedSearchText) }
            mapView.stationsMap.clear()
            addStationsToMap()
        } else {
            stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
            addStationsToMap()
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: Alarm Functions
    func showAlarmsView() {
        print("ALARMS ARE \(napper.destination[0].name)")
        if showAlarms {
            navigationItem.title = "Alarms"
            navigationItem.rightBarButtonItem?.title = "Map"
            alarmsListView.alarmsTableView.reloadData()
            alarmsListView.isHidden = false
            mapView.isHidden = true
        } else {
            navigationItem.title = "TrainNapper"
            navigationItem.rightBarButtonItem?.title = "Alarms"
            alarmsListView.isHidden = true
            mapView.isHidden = false
        }
        
        showAlarms = !showAlarms
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return napper.destination.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        let destinationName = napper.destination[indexPath.row].name
        cell.textLabel?.text = destinationName
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    
    
    func addAlarm(_ sender: GMSMarker) {
        
        guard let myDestination = store.stationsDictionary[sender.title!] else { print("error setting alarm"); return }
        guard let napperLocation = napper.coordinate else { print("error getting napper coordinate"); return }
        
        // Adds station to napper's destination array
        napper.destination.append(myDestination)
        
        // Sorts destination array by proximity
        if napper.destination.count > 1 {
            napper.destination = napper.destination.sorted(by: { ($0.coordinateCL.distance(from: napperLocation) < $1.coordinateCL.distance(from: napperLocation))
            })
        }
        
         
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
        
        
        
    }
    
    func removeAlarm(_ sender: GMSMarker) {
        guard let myDestination = store.stationsDictionary[sender.title!] else { print("error removing alarm destination"); return }
        
        for (index, destination) in napper.destination.enumerated() {
            if destination.name == myDestination.name {
                napper.destination.remove(at: index)
            }
        }
        
    }
}



// MARK: GMSMapViewDelegate

extension HomeViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
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
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
            guard let unwrappedLocation = locationManager.location else { print("error initializing user's location"); return }
            napper.coordinate = unwrappedLocation
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("DID ENTER THE REGION!!!!!!")
        
        let alert = UIAlertController(title: "WAKE UP!", message: "You are now arriving at your destination", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}

extension HomeViewController {
    
    

    func registerLocal() {

        
    }

    
}

