//
//  Privacy.swift
//  enHueco
//
//  Created by Diego Gómez on 8/12/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

class PrivacySettings: Object {

    struct JSONKeys {
        private init() {}

        static let userID = "user_id"
        static let showEventsNames = "show_events_names"
        static let showEventsLocations = "show_events_locations"
        static let invisibilityEndDate = "invisibility_end_date"
    }

    let userID: String
    let invisibilityEndDate: NSDate?
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
        try super.init(map: Map(json: [:]))
    }

    required init(map: Map) throws {
        
        userID = try map.extract(.Key(JSONKeys.userID))
        showEventsNames = try map.extract(.Key(JSONKeys.showEventsNames))
        showEventsLocations = try map.extract(.Key(JSONKeys.showEventsLocations))
        invisibilityEndDate = try map.extract(.Key(JSONKeys.showEventsLocations), transformer: GenomeTransformers.fromJSON)
        try super.init(map: map)
    }
}
