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

    var napper: Napper!

    var mapView: MapView!
    var mapViewModel: MapViewModel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var filterView = FilterView()
    var showFilter = false

    
    var alarmsListView: AlarmsListView!
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
    
    
    func initializeUserLocation() {

//        mapView.stationsMap.delegate = self
//        guard let unwrappedLocation = napperViewModel.locationManager.location else { print("error initializing user's location in configure()"); return }
//        napper = Napper(coordinate: unwrappedLocation, destination: [store.lirrStationsArray[0]])
    }
    
    // MARK: Initial Setup
    func configure() {
        mapView = MapView()
        mapViewModel = MapViewModel()
        alarmsListView = AlarmsListView()
        
        mapViewModel.filterDelegate = mapView
        mapViewModel.addStationsToMap()
        
        // Initializes advertising banner
        mapView.advertisingView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        mapView.advertisingView.load(request)
        
        // Sets up navigationBar
        navigationItem.title = "TrainNapper"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        /*navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Alarms", style: .plain, target: self, action: #selector(showAlarmsView))
        

        
        // Sets up TableView
        alarmsListView.alarmsTableView.delegate = self
        alarmsListView.alarmsTableView.dataSource = self
        alarmsListView.alarmsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlarmCell")
        alarmsListView.isHidden = true
        
        */
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
        
//        filterView.searchView.addSubview(searchBar)
//        searchBar.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
        
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
    

    
}
/*

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
        
        /*
         // Creates an alarm using Region Monitoring
         for destination in napper.destination {
         let region = CLCircularRegion(center: destination.coordinate2D, radius: proximityRadius, identifier: destination.name)
         region.notifyOnEntry = true
         region.notifyOnExit = false
         locationManager.startMonitoring(for: region)
         print("Monitored Regions count: \(locationManager.monitoredRegions.count)")
         
         }
         */
         
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


*/
// MARK: GMSMapViewDelegate

extension HomeViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    
    
    
}


