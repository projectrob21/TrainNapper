//
//  LocationManager.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/22/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import GoogleMaps

protocol AddToMapDelegate: class {
    func addStationsToMap(stations: [GMSMarker])
}

protocol FilterBranchesDelegate: class {
    func filterBranches(sender: UIButton)
}

protocol NapperAlarmsDelegate: class {
    func addAlarm(station: Station)
    func removeAlarm(station: Station)
}

final class MapViewModel: NSObject {
    
    let store = DataStore.sharedInstance
    var stations = [Station]()
    
    var markerWindowView: MarkerWindowView!
    
    weak var addToMapDelegate: AddToMapDelegate?
    weak var napperAlarmsDelegate: NapperAlarmsDelegate?
    
    
    override init() {
        super.init()
        configure()
    }
    
    func configure() {
        store.populateAllStations()
        stations = store.lirrStationsArray + store.metroNorthStationsArray + store.njTransitStationsArray
    }
    
    
    func addStationsToMap() {
        var markerArray = [GMSMarker]()
        for station in stations {
            
            let marker = GMSMarker(position: station.coordinate2D)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.title = station.name
            switch station.branch {
            case .LIRR: marker.icon = GMSMarker.markerImage(with: .lirrColor)
            case .MetroNorth: marker.icon = GMSMarker.markerImage(with: .metroNorthColor)
            case .NJTransit: marker.icon = GMSMarker.markerImage(with: .njTransitColor)
            default: break
            }
            markerArray.append(marker)
            
        }
        addToMapDelegate?.addStationsToMap(stations: markerArray)
    }
    
}

extension MapViewModel: FilterBranchesDelegate {
    
    func filterBranches(sender: UIButton) {
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
extension MapViewModel: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        markerWindowView = MarkerWindowView()
        markerWindowView.stationLabel.text = marker.title
        return markerWindowView
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        guard let selectedStation = store.stationsDictionary[marker.title!] else { print("error getting station from dictionary"); return }
        
        if marker.snippet == nil {
            napperAlarmsDelegate?.addAlarm(station: selectedStation)

            marker.icon = GMSMarker.markerImage(with: .blue)
            marker.snippet = "Station selected"
        } else {
            napperAlarmsDelegate?.removeAlarm(station: selectedStation)
            
            switch selectedStation.branch {
            case .LIRR: marker.icon = GMSMarker.markerImage(with: .lirrColor)
            case .MetroNorth: marker.icon = GMSMarker.markerImage(with: .metroNorthColor)
            case .NJTransit: marker.icon = GMSMarker.markerImage(with: .njTransitColor)
            default: break
                
            }
            marker.snippet = nil
            
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




