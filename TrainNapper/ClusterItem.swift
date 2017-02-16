//
//  ClusterItem.swift
//  TrainNapper
//
//  Created by Robert Deans on 2/15/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation

class StationCluster: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var icon: UIImage?
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
