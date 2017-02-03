//
//  LocationManager.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import GoogleMaps

protocol AddToMapDelegate: class {
    func addStationsToMap(stations: StationDictionary)
}

protocol FilterBranchesDelegate: class {
    func filterBranches(branch: Branch, isHidden: Bool)
}

final class MapViewModel: NSObject {
    
    let store = DataStore.sharedInstance
    var stations: StationDictionary = [:]

    var markerWindowView: MarkerWindowView!
    var markerArray = [GMSMarker]()

    weak var addToMapDelegate: AddToMapDelegate?
    weak var napperAlarmsDelegate: NapperAlarmsDelegate?
    
    
    override init() {
        super.init()
        configure()
    }
    
    func configure() {
        store.populateAllStations()
        stations = store.stationsDictionary
    }
    
    
    func reloadStationsMap(with stations: StationDictionary) {
        print("reload stations")
        addToMapDelegate?.addStationsToMap(stations: stations)
    }
    
}


extension MapViewModel: FilterBranchesDelegate {
    
    func filterBranches(branch: Branch, isHidden: Bool) {
        print("filter branches delegate tapped")
        if isHidden {
            switch branch {
            case .LIRR:
                for (key, station) in stations {
                    if station.branch == .LIRR {
                        stations[key]?.isHidden = true
                    }
                }
            case .MetroNorth:
                for (key, station) in stations {
                    if station.branch == .MetroNorth  {
                        stations[key]?.isHidden = true
                    }
                }
            case .NJTransit:
                for (key, station) in stations {
                    if station.branch == .NJTransit  {
                        stations[key]?.isHidden = true
                    }
                }
            default: break
            }
        } else {
            switch branch {
            case .LIRR:
                for (key, station) in stations {
                    if station.branch == .LIRR  {
                        stations[key]?.isHidden = false
                    }
                }
            case .MetroNorth:
                for (key, station) in stations {
                    if station.branch == .MetroNorth  {
                        stations[key]?.isHidden = false
                    }
                }
            case .NJTransit:
                for (key, station) in stations {
                    if station.branch == .NJTransit  {
                        stations[key]?.isHidden = false
                    }
                }
            default: break
            }
        }
        reloadStationsMap(with: stations)
    }
    
}


extension MapViewModel: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        print("stations count is \(stations.count)")
        print("search text: \(lowercasedSearchText)")
        var searchStations = stations
        
        if lowercasedSearchText != "" {
            for (key, station) in searchStations {
                if !station.name.lowercased().contains(lowercasedSearchText) {
                    searchStations[key]?.isHidden = true
                }
            }
            reloadStationsMap(with: searchStations)
        } else {
            for (key, station) in stations {
                if !station.name.lowercased().contains(lowercasedSearchText) {
                    stations[key]?.isHidden = false
                }
            }
            reloadStationsMap(with: searchStations)
        }
    }
    
    
}



