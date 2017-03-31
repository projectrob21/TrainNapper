//
//  AlarmPin.swift
//  TrainNapper
//
//  Created by Robert Deans on 3/31/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import RealmSwift

final class Alarm: Object {

    dynamic var id: UUID?
    dynamic var name: String? = nil
    dynamic var location: Location?
    dynamic var isActive: Bool = true
    
}
