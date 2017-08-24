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

//
protocol AddToMapDelegate: class {
    func addStationsToMap(stations: StationDictionary)
}

//
protocol FilterBranchesDelegate: class {
    func filterBranches(branch: Branch, isHidden: Bool)
}

//
protocol SearchStationDelegate: class {
    func searchBarFilter(with text: String)
}
