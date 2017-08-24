//
//  HelperProtocols.swift
//  TrainNapper
//
//  Created by Robert Deans on 8/24/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation

// Used by Napper to notify ViewController to alert user
protocol PresentAlertDelegate: class {
    func presentAlert()
}

// Used by MapView to notify DestinationVM to add/remove alarms
protocol NapperAlarmsDelegate: class {
    func addAlarm(station: Station)
    func removeAlarm(station: Station)
}

// Used by MapViewModel to add stations to MapView; communicates in tandem with FilterFrancesDelegate
protocol AddToMapDelegate: class {
    func addStationsToMap(stations: StationDictionary)
}

// Used by MapView to alert MapViewModel to filter stations; communicates in tandem with AddToMapDelegate
protocol FilterBranchesDelegate: class {
    func filterBranches(branch: Branch, isHidden: Bool)
}

// Used by MapView to alert MapViewModel to filter stations bu UISearchBar; communicates in tandem with AddToMapDelegate
protocol SearchStationDelegate: class {
    func searchBarFilter(with text: String)
}

// Used by Napper to describe distance to HomeVC, which provides views for testing
protocol GetDistanceDelegate: class {
    func distanceToStation(distance: Double)
}
