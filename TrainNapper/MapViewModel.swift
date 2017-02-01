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
    var stations = [String:Station]()
    
    var markerWindowView: MarkerWindowView!
    
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
    
    
    func addStationsToMap() {
        var markerArray = [GMSMarker]()
        for (_, station) in stations {
            
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
                for (key, station) in stations {
                    if station.branch == .LIRR  {
                        stations.removeValue(forKey: key)
                    }
                }
            case "Metro North":
                for (key, station) in stations {
                    if station.branch == .MetroNorth  {
                        stations.removeValue(forKey: key)
                    }
                }
            case "NJ Transit":
                for (key, station) in stations {
                    if station.branch == .NJTransit  {
                        stations.removeValue(forKey: key)
                    }
                }
            default: break
            }
            addStationsToMap()
            sender.backgroundColor = UIColor.gray
            
        } else {
            switch stationName {
            case "LIRR":
                store.getJSONStationsDictionary(with: "LIRRStations", completion: { (lirrJSON) in
                    if let stationsDictionary = lirrJSON["stops"]?["stop"] as? [[String : Any]] {
                        for stationDict in stationsDictionary.map({ Station(jsonData: $0) }) {
                            self.stations[stationDict.name] = stationDict
                        }
                    }
                })
            case "Metro North":
                store.getJSONStationsDictionary(with: "MetroNorthStations", completion: { (metroNorthJSON) in
                    if let stationsDictionary = metroNorthJSON["stops"]?["stop"] as? [[String : Any]] {
                        for stationDict in stationsDictionary.map({ Station(jsonData: $0) }) {
                            self.stations[stationDict.name] = stationDict
                        }
                    }
                })
            case "NJ Transit":
                store.getJSONStationsDictionary(with: "NJTransit", completion: { (njtJSON) in
                    if let stationsDictionary = njtJSON["stops"]?["stop"] as? [[String : Any]] {
                        for stationDict in stationsDictionary.map({ Station(jsonData: $0) }) {
                            self.stations[stationDict.name] = stationDict
                        }
                    }
                })
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
            
            for (key, station) in stations {
                if !station.name.lowercased().contains(lowercasedSearchText) {
                    stations.removeValue(forKey: key)
                }
            }
            addStationsToMap()
        } else {
            stations = store.stationsDictionary
            addStationsToMap()
        }
    }
    
    
}




