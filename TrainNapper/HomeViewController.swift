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
    
    let napper = sharedDelegate.napper
    let store = StationsDataStore.sharedInstance

    let mapView = MapView()
    
    var alarmsListView: AlarmsListView!
    var bannerView: GADBannerView!
    
    let mapViewModel = MapViewModel()
    var destinationViewModel: DestinationViewModel!
    
    var showAlarms = false
    var showFilter = false
    
    var distanceLabel: UILabel!

    var backgroundGradient: CAGradientLayer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        constrain()
        
        
        // Sets gradient after constraints have been made
        backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UIColor.mainColor.cgColor, UIColor.clear.cgColor]
        backgroundGradient.locations = [0, 1]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0.1)
        backgroundGradient.endPoint = CGPoint(x: 0, y: 1)
        let width = self.view.frame.width
        backgroundGradient.frame = CGRect(x: 0, y: 0, width: width, height: 44)
        mapView.filterView.layer.insertSublayer(backgroundGradient, at: 0)
        
        
    }
    
    
    // MARK: Initial Setup
    func configure() {
        
        alarmsListView = AlarmsListView(napper: napper)
        destinationViewModel = DestinationViewModel(napper: napper)
        
        // Sets up navigationBar
        navigationItem.title = "TrainNapper"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Alarms", style: .plain, target: self, action: #selector(toggleAlarmsListView))
        alarmsListView.isHidden = true

        // Sets up advertising
        bannerView = GADBannerView()
        bannerView.adUnitID = "ca-app-pub-2779558823377577/7704036846"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-2779558823377577/7704036846"]
        bannerView.load(request)
        

        
        // Assigning delegates
        mapView.filterView.searchStationDelegate = mapViewModel
        mapView.filterBranchesDelegate = mapViewModel
        mapView.napperAlarmsDelegate = destinationViewModel
        alarmsListView.napperAlarmsDelegate = destinationViewModel
        mapViewModel.addToMapDelegate = mapView
        destinationViewModel.regionsToMonitorDelegate = napper
//        destinationViewModel.distanceDelegate = self
        napper.presentAlertDelegate = self

        
        mapView.addStationsToMap(stations: mapViewModel.stations)

        // HomeVC needs time to initialize and set delegate before calling this method
        sharedDelegate.napper.requestLocationAuthorization()
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
        
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(10)
        }
        // Used to test region distances
        /*
        distanceLabel = UILabel()
        mapView.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints {
            $0.bottom.leading.width.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(8)
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
    
    func toggleAlarmsListView() {
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
            mapViewModel.reloadStationsMap(with: store.stationsDictionary)
            alarmsListView.isHidden = true
            mapView.isHidden = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(toggleFilterView))
        }
    }
    
}

extension HomeViewController: GetDistanceDelegate {
    func distanceToStation(distance: Double) {
        distanceLabel.text = "\(distance)"
    }
}

extension HomeViewController: PresentAlertDelegate {
    func presentAlert() {
        print("present alert delegate called")
        
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "In order to be notified of upcoming stations, please open this app's settings and set location access to 'Always'.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

