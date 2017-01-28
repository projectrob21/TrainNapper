//
//  ViewController.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds


class HomeViewController: UIViewController {
    
    var mapView: MapView!
    var mapViewModel: MapViewModel!
    var napperViewModel: NapperViewModel!
    
    var alarmsListView: AlarmsListView!
    var showAlarms = false
    var showFilter = false
    
    var advertisingView: GADBannerView!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        constrain()
        

        /*
        let alert = UIAlertController(title: "WAKE UP!", message: "You are now arriving at your destination", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil) 
         */
        
    }

    
    // MARK: Initial Setup
    func configure() {
        mapView = MapView()
        mapViewModel = MapViewModel()
        napperViewModel = NapperViewModel()
        alarmsListView = AlarmsListView()
        
        // Assigning delegates
        mapViewModel.addToMapDelegate = mapView
        mapView.stationsMap.delegate = mapViewModel
        mapView.filterView.searchBar.delegate = mapViewModel
        mapView.filterBranchesDelegate = mapViewModel
        
        mapViewModel.napperAlarmsDelegate = napperViewModel
        alarmsListView.alarmsTableView.delegate = napperViewModel
        alarmsListView.alarmsTableView.dataSource = napperViewModel
        
        alarmsListView.isHidden = true

        
        // Must assign delegates before adding stations to map!
        mapViewModel.addStationsToMap()
        
        // Initializes advertising banner
        advertisingView = GADBannerView()
        advertisingView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        advertisingView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        advertisingView.load(request)
        
        // Sets up navigationBar
        navigationItem.title = "TrainNapper"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Alarms", style: .plain, target: self, action: #selector(showAlarmsView))

        
    }
    
    func constrain() {
        
        view.addSubview(alarmsListView)
        alarmsListView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.9)
        }
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.9)
        }
        
        view.addSubview(advertisingView)
        advertisingView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(10)
        }
        // Used to test region distances
        /*
        var distanceLabel = UILabel()
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
        showAlarms = !showAlarms

        if showAlarms {
            navigationItem.title = "Alarms"
            navigationItem.rightBarButtonItem?.title = "Map"
            alarmsListView.alarmsTableView.reloadData()
            alarmsListView.isHidden = false
            mapView.isHidden = true
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.title = "TrainNapper"
            navigationItem.rightBarButtonItem?.title = "Alarms"
            alarmsListView.isHidden = true
            mapView.isHidden = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        }
    }
    
}



