//
//  JSONSerializer.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import Foundation

final class DataStore {
    
    static let sharedInstance = DataStore()

    var lirrStationsArray = [Station]()
    var metroNorthStationsArray = [Station]()
    var njTransitStationsArray = [Station]()
    var stationsDictionary: Dictionary = [String:Station]()
    
    func getJSONStationsDictionary(with jsonFilename: String, completion: @escaping ([String : [String : Any]]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: jsonFilename, ofType: "json") else { print("error unwrapping json file path"); return }
        
        do {
            let data = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            
            guard let stationDictionary = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String : [String : Any]] else { print("error typecasting json dictionary"); return }
            completion(stationDictionary)
        } catch {
            print("error reading data from file in json serializer")
        }
    }
    
    func populateLIRRStationsFromJSON() -> [String:Station] {
        var lirrDictionary = [String:Station]()

        getJSONStationsDictionary(with: "LIRRStations") { lirrJSON in
            self.lirrStationsArray = []
            if let stationsDictionary = lirrJSON["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.stationsDictionary[station.name] = station
                    lirrDictionary[station.name] = station
                    self.lirrStationsArray.append(station)
                }
            }
        }
        return lirrDictionary
    }
    
    func populateMetroNorthStationsFromJSON() -> [String:Station] {
        var metroNorthDictionary = [String:Station]()

        getJSONStationsDictionary(with: "MetroNorthStations") { (metroNorthJSON) in
            self.metroNorthStationsArray = []
            if let stationsDictionary = metroNorthJSON["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.stationsDictionary[station.name] = station
                    metroNorthDictionary[station.name] = station
                    self.metroNorthStationsArray.append(station)
                }
            }
        }
        return metroNorthDictionary
    }
    
    func populateNJTStationsFromJSON() -> [String:Station] {
        var njTransitDictionary = [String:Station]()

        getJSONStationsDictionary(with: "NJTransit") { njTransitJSON in
            self.njTransitStationsArray = []
            if let stationsDictionary = njTransitJSON["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.stationsDictionary[station.name] = station
                    njTransitDictionary[station.name] = station
                    self.njTransitStationsArray.append(station)
                }
            }
        }
        return njTransitDictionary
    }
    
    func populateAllStations() {
        stationsDictionary = [String:Station]()
        populateLIRRStationsFromJSON()
        populateMetroNorthStationsFromJSON()
        populateNJTStationsFromJSON()
    }
}
