//
//  LocationManager.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import GoogleMaps

protocol AddToMapDelegate: class {
    func addStationsToMap(stations: [GMSMarker])
}

protocol FilterBranchesDelegate: class {
    func filterBranches(sender: UIButton)
}

final class MapViewModel: NSObject {
    
    let store = DataStore.sharedInstance
    var stations = [Station]()
    
    weak var addToMapDelegate: AddToMapDelegate?
    
    var markerWindowView: MarkerWindowView!
    var tappedMarker = GMSMarker()
    var proximityRadius = 6275.0
    
    var showFilter = false

    override init() {
        super.init()
        configure()
    }
    
    func configure() {
        store.populateAllStations()
        stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
        addStationsToMap()
        
    }
    
    
    func addStationsToMap() {
        var markerArray = [GMSMarker]()
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
            
            markerArray.append(marker)
            
        }
        print("ADD STATIONS MAP RUNNING IN VIEWMODEL WITH \(markerArray.count) MARKERS")
        addToMapDelegate?.addStationsToMap(stations: markerArray)
        
    }
}

extension MapViewModel: FilterBranchesDelegate {
    
    func filterBranches(sender: UIButton) {
        print("delegate sent message")
        guard let stationName = sender.titleLabel?.text else { print("could not retrieve station name"); return }
        
        if sender.backgroundColor == UIColor.filterButtonColor {
            
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

extension MapViewModel: UISearchBarDelegate {
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        print("stations count is \(stations.count)")
        print("search text: \(lowercasedSearchText)")
        if lowercasedSearchText != "" {
            stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
            stations = stations.filter { $0.name.lowercased().contains(lowercasedSearchText) }
            addStationsToMap()
        } else {
            stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
            addStationsToMap()
        }
    }
    
}


