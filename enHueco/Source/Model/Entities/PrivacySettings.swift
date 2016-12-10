//
//  Privacy.swift
//  enHueco
//
//  Created by Diego Gómez on 8/12/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import Genome
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PrivacySettings: Object {

    struct JSONKeys {
        fileprivate init() {}

        static let userID = "user_id"
        static let showEventsNames = "show_events_names"
        static let showEventsLocations = "show_events_locations"
        static let invisibilityEndDate = "invisibility_end_date"
    }

    let userID: String
    let invisibilityEndDate: Date?
    let showEventsNames: Bool
    let showEventsLocations: Bool
    
    var invisible: Bool {
        return invisibilityEndDate?.timeIntervalSinceNow < 0
    }
    
    ///Temporary 
    init() throws {
        invisibilityEndDate = nil
        userID = ""
        showEventsNames = true
        showEventsLocations = true
        try super.init(map: Map(node: [:]))
    }

    required init(map: Map) throws {
        
        userID = try map.extract(JSONKeys.userID)
        showEventsNames = try map.extract(JSONKeys.showEventsNames)
        showEventsLocations = try map.extract(JSONKeys.showEventsLocations)
        invisibilityEndDate = try map.extract(JSONKeys.showEventsLocations)
        try super.init(map: map)
    }
}
