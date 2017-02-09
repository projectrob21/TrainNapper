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
        print("addstationstomap delegate hit")
        stationsMap.clear()
        
        for (_, station) in stations {
            
            if !station.isHidden {
                let marker = GMSMarker(position: station.coordinate2D)
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.title = station.name
                switch station.branch {
                case .LIRR: marker.icon = UIImage.lirrIcon
//                    = GMSMarker.markerImage(with: .lirrColor)
                case .MetroNorth: marker.icon = UIImage.metroNorthIcon
//                    = GMSMarker.markerImage(with: .metroNorthColor)
                case .NJTransit: marker.icon = UIImage.njTransitIcon
//                    = GMSMarker.markerImage(with: .njTransitColor)
                default: break
                }
                if station.isSelected {
                    marker.icon = GMSMarker.markerImage(with: .blue)
                }
                marker.map = stationsMap
            }
        }
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
        markerWindowView.stationLabel.text = marker.title
        return markerWindowView
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let station = store.stationsDictionary[marker.title!] else { print("mapview - trouble unwrapping station"); return }
        
        if marker.snippet == nil {
            napperAlarmsDelegate?.addAlarm(station: station)
            marker.icon = UIImage.alarmClock
            marker.snippet = "Station selected"
        } else {
            napperAlarmsDelegate?.removeAlarm(station: station)
            marker.snippet = nil
            
            switch station.branch {
                case .LIRR: marker.icon = UIImage.lirrIcon
                case .MetroNorth: marker.icon = UIImage.metroNorthIcon
                case .NJTransit: marker.icon = UIImage.njTransitIcon
                default: break
            }
        }
    }
}
