//
//  Privacy.swift
//  enHueco
//
//  Created by Diego Gómez on 8/12/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

class Privacy {
    
    let userID: String
    
    let showEventsNames: Boolean
    
    let showEventsLocations: Boolean
    
    
    //var name: String { return "\(firstNames) \(lastNames)" }
    
    init(map: Map) throws {
        userID = try map.extract("user_id")
        showEventsNames = try map.extract("show_events_names")
        showEventsLocations = try map.extract("show_events_locations")
    }

}
