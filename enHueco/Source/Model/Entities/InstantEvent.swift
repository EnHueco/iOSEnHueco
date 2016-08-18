//
//  InstantEvent.swift
//  enHueco
//
//  Created by Diego Gómez on 8/12/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

/// The type of the Instant Event
enum InstantEventType: String {
    case FreeTime = "FREE_TIME", Invisibility = "INVISIBILITY"
}

class InstantEvent: MappableObject {
    
    struct JSONKeys {
        private init() {}
        
        static let userID = "user_id"
        static let type = "type"
        static let name = "name"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let location = "location"
    }
    
    let userID: String
    let type : InstantEventType
    let name: String?
    let location: String?
    let startDate: NSDate
    let endDate: NSDate
    
    init(type: InstantEventType, name: String?, location: String?, startDate: NSDate, endDate: NSDate) {
        
        self.type = type
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.repetitionDays = repetitionDays
    }
        
    init(map: Map) throws {
        
        userID = try map.extract(JSONKeys.id)
        type = try map[JSONKeys.ty].fromJson { EventType(rawValue: $0)! }
        name = try map.extract(JSONKeys.name)
        
        // To do: Set start & end dates based on JSON data
        location = try map.extract(JSONKeys.location)
    }
}
