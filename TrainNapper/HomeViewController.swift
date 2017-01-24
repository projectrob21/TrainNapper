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
    var mapView: MapView!
    var mapViewModel: MapViewModel!

    var napperViewModel: NapperViewModel!
    
    var alarmsListView: AlarmsListView!
    var showAlarms = false
    var showFilter = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        mapView = MapView()
        mapViewModel = MapViewModel()
        napperViewModel = NapperViewModel()
        alarmsListView = AlarmsListView()
        
        // Assing delegates
        mapViewModel.addToMapDelegate = mapView
        mapView.filterView.searchBar.delegate = mapViewModel
        mapView.filterBranchesDelegate = mapViewModel
        mapView.stationsMap.delegate = mapViewModel
        mapViewModel.napperAlarmsDelegate = napperViewModel
        
        alarmsListView.alarmsTableView.delegate = napperViewModel
        alarmsListView.alarmsTableView.dataSource = napperViewModel
        alarmsListView.alarmsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlarmCell")
        alarmsListView.isHidden = true

        
        // Must assign delegates before adding stations to map!
        mapViewModel.addStationsToMap()
        
        // Initializes advertising banner
        mapView.advertisingView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        mapView.advertisingView.load(request)
        
        // Sets up navigationBar
        navigationItem.title = "TrainNapper"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Alarms", style: .plain, target: self, action: #selector(showAlarmsView))
        
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
        
        
        // Used to test region distances
        /*
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
        */
    }
    

    
    func toggleFilterView() {
        showFilter = !showFilter
        view.layoutIfNeeded()
        if showFilter {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.mapView.filterView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalToSuperview()
                    $0.height.equalTo(50)
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.mapView.filterView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.bottom.equalTo(self.mapView.stationsMap.snp.top).offset(-132)
                    $0.height.equalTo(64)
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func showAlarmsView() {
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
    
}



