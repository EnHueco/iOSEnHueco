//
//  Privacy.swift
//  enHueco
//
//  Created by Diego Gómez on 8/12/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

class PrivacySettings: MappableObject {

    struct JSONKeys {
        private init() {}

        static let userID = "user_id"
        static let showEventsNames = "show_events_names"
        static let showEventsLocations = "show_events_locations"
    }

    let userID: String
    let showEventsNames: Bool
    let showEventsLocations: Bool

    //var name: String { return "\(firstNames) \(lastNames)" }

    required init(map: Map) throws {
        userID = try map.extract(.Key(JSONKeys.userID))
        showEventsNames = try map.extract(.Key(JSONKeys.showEventsNames))
        showEventsLocations = try map.extract(.Key(JSONKeys.showEventsLocations))
    }
}
