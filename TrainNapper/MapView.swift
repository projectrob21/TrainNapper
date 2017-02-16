//
//  MapView.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps
import GoogleMobileAds

class MapView: UIView {
    
    // MARK: Properties
    
    let store = DataStore.sharedInstance
    
    var camera: GMSCameraPosition!
    var stationsMap: GMSMapView!
    var markerWindowView: MarkerWindowView!
    var clusterManager: GMUClusterManager!
    var markerArray = [GMSMarker]()
    
    let filterView = FilterView()
    
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

        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [10,20,50,100,200,400])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: stationsMap,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: stationsMap, algorithm: algorithm,
                                           renderer: renderer)
        renderer.delegate = self
        clusterManager.setDelegate(self, mapDelegate: self)
        
        
        
        
        
        for button in filterView.buttonsArray {
            button.addTarget(self, action: #selector(filterBranches(_:)), for: .touchUpInside)
        }
    }
    
    // MARK: View Constraints
    func constrain() {
        
        addSubview(stationsMap)
        stationsMap.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(filterView)
        filterView.snp.makeConstraints {
            $0.leading.trailing.width.equalToSuperview()
            $0.bottom.equalTo(stationsMap.snp.top).offset(-132)
            $0.height.equalTo(44)
            
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
                switch station.branch {
                    case .LIRR:
                        clusterStation.icon = UIImage.lirrIcon
                    case .MetroNorth:
                        clusterStation.icon = UIImage.metroNorthIcon
                    case .NJTransit:
                        clusterStation.icon = UIImage.njTransitIcon
                    default: break
                }
                if station.isSelected {
                    clusterStation.icon = UIImage.alarmClock
                }
                clusterManager.add(clusterStation)
            }
        }
        clusterManager.cluster()
    }
    
    func filterBranches(_ sender: UIButton) {
        guard let stationName = sender.titleLabel?.text else { print("could not retrieve station name"); return }
        
        if sender.backgroundColor == UIColor.filterButtonColor {
            
            switch stationName {
            case "LIRR":
                filterBranchesDelegate?.filterBranches(branch: Branch.LIRR, isHidden: true)
            case "Metro North":
                filterBranchesDelegate?.filterBranches(branch: Branch.MetroNorth, isHidden: true)
            case "NJ Transit":
                filterBranchesDelegate?.filterBranches(branch: Branch.NJTransit, isHidden: true)
            default: break
            }
            sender.backgroundColor = UIColor.gray
            
        } else {
            switch stationName {
            case "LIRR":
                filterBranchesDelegate?.filterBranches(branch: Branch.LIRR, isHidden: false)
            case "Metro North":
                filterBranchesDelegate?.filterBranches(branch: Branch.MetroNorth, isHidden: false)
            case "NJ Transit":
                filterBranchesDelegate?.filterBranches(branch: Branch.NJTransit, isHidden: false)
            default: break
            }
            sender.backgroundColor = UIColor.filterButtonColor
        }
    }
}

extension MapView: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        markerWindowView = MarkerWindowView()
        markerWindowView.stationLabel.text = marker.snippet
        return markerWindowView
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
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
    }
}

extension MapView: GMUClusterManagerDelegate, GMUClusterRendererDelegate {

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        print("rendering")
        print("marker.userData = )")

        
        
        guard let stationData = marker.userData as? StationCluster else { print("error unwrapping station in willRenderMarker"); return }
        
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
