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

protocol ChangeMarkerColorDelegate: class {
    func changeMarkerColor(for stationName: String)
}

protocol GetMapViewDelegate: class {
    func getInfoForMap() -> GMSMapView
}

final class MapViewModel: NSObject {
    
    let store = DataStore.sharedInstance
    var stations = [String:Station]()
    
    var markerWindowView: MarkerWindowView!
    var markerArray = [GMSMarker]()

    weak var addToMapDelegate: AddToMapDelegate?
    weak var napperAlarmsDelegate: NapperAlarmsDelegate?
    weak var getMapViewDelegate: GetMapViewDelegate?
    
    
    override init() {
        super.init()
        configure()
    }
    
    func configure() {
        store.populateAllStations()
        stations = store.stationsDictionary
    }
    
    
    func addStationsToMap() {
        markerArray = [GMSMarker]()

        for (_, station) in stations {
            
            if !station.isHidden {
                let marker = GMSMarker(position: station.coordinate2D)
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.title = station.name
                switch station.branch {
                    case .LIRR: marker.icon = GMSMarker.markerImage(with: .lirrColor)
                    case .MetroNorth: marker.icon = GMSMarker.markerImage(with: .metroNorthColor)
                    case .NJTransit: marker.icon = GMSMarker.markerImage(with: .njTransitColor)
                    default: break
                }
                if station.isSelected {
                    marker.icon = GMSMarker.markerImage(with: .blue)
                }
                markerArray.append(marker)
            }
        }
        addToMapDelegate?.addStationsToMap(stations: markerArray)
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
            stations[marker.title!]?.isSelected = true
            marker.snippet = "Station selected"
        } else {
            napperAlarmsDelegate?.removeAlarm(station: selectedStation)
            
            switch selectedStation.branch {
                case .LIRR: marker.icon = GMSMarker.markerImage(with: .lirrColor)
                case .MetroNorth: marker.icon = GMSMarker.markerImage(with: .metroNorthColor)
                case .NJTransit: marker.icon = GMSMarker.markerImage(with: .njTransitColor)
                default: break
            }
            stations[marker.title!]?.isSelected = false
            marker.snippet = nil
            
        }
    }
}

extension MapViewModel: ChangeMarkerColorDelegate {
    
    func changeMarkerColor(for stationName: String) {
        print("Chamge marker color called in mapviewmodel")

        guard let gmsMapView = getMapViewDelegate?.getInfoForMap() else { print("error getting GMSMapview"); return }
        
        for marker in markerArray {
            if marker.title == stationName {
                mapView(gmsMapView, didTapInfoWindowOf: marker)

            }
        }
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
                        stations[key]?.isHidden = true
                    }
                }
            case "Metro North":
                for (key, station) in stations {
                    if station.branch == .MetroNorth  {
                        stations[key]?.isHidden = true
                    }
                }
            case "NJ Transit":
                for (key, station) in stations {
                    if station.branch == .NJTransit  {
                        stations[key]?.isHidden = true
                    }
                }
            default: break
            }
            addStationsToMap()
            sender.backgroundColor = UIColor.gray
            
        } else {
            switch stationName {
            case "LIRR":
                for (key, station) in stations {
                    if station.branch == .LIRR  {
                        stations[key]?.isHidden = false
                    }
                }
            case "Metro North":
                for (key, station) in stations {
                    if station.branch == .MetroNorth  {
                        stations[key]?.isHidden = false
                    }
                }
            case "NJ Transit":
                for (key, station) in stations {
                    if station.branch == .NJTransit  {
                        stations[key]?.isHidden = false
                    }
                }
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
            
            for (key, station) in stations {
                if !station.name.lowercased().contains(lowercasedSearchText) {
                    stations[key]?.isHidden = true
                }
            }
            addStationsToMap()
        } else {
            for (key, station) in stations {
                if !station.name.lowercased().contains(lowercasedSearchText) {
                    stations[key]?.isHidden = false
                }
            }
            addStationsToMap()
        }
    }
    
    
}




