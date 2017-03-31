//
//  User.swift
//  TrainNapper
//
//  Created by Robert Deans on 3/31/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {
    
    let alarms = List<Alarm>()
    dynamic var coordinate: Location?

}
