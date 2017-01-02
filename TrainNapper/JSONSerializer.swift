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
    var lirrStationsDictionary: Dictionary = [String:Station]()
    
    func getJSONStationsDictionary(completion: @escaping ([String : [String : Any]]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "LIRRStations", ofType: "json") else {
            print("error unwrapping json file path")
            return
        }
        
        do {
            let data = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            
            guard let lirrDictionary = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String : [String : Any]] else {
                print("error typecasting json dictionary")
                return
            }
            
            completion(lirrDictionary)
        } catch {
            print("error reading playground data from file in json serializer")
        }
    }
    
    func populateLIRRStationsFromJSON() {
        getJSONStationsDictionary { lirrDictionary in
            self.lirrStationsArray = []
            self.lirrStationsDictionary = [String:Station]()
            if let stationsDictionary = lirrDictionary["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.lirrStationsDictionary[station.name] = station
                    self.lirrStationsArray.append(station)
                }
                
            }
        }
        
    }
}
