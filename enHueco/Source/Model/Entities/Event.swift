//
//  Event.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 9/22/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

/// A calendar event (class or free time at the moment)

class Event: BaseEvent, Equatable {

    struct JSONKeys {
        private init() {}

        static let userID = "user_id"
        static let id = "id"
    }

    let userID: String
    let id: String
    
    init(userID: String, id: String, type: EventType, name: String?, location: String?, startDate: NSDate, endDate: NSDate, repeating: Bool) {
        
        self.userID = userID
        self.id = id
        
        super.init(type: type, name: name, location: location, startDate: startDate, endDate: endDate, repeating: repeating)
    }

    required init(map: Map) throws {
        
        userID = try map.extract(.Key(JSONKeys.userID))
        id = try map.extract(.Key(JSONKeys.id))

        try super.init(map: map)
    }
    
    override func sequence(map: Map) throws {
                
        try userID ~> map[.Key(JSONKeys.userID)]
        try id ~> map[.Key(JSONKeys.id)]
        
        try super.sequence(map)
    }
}

func < (lhs: Event, rhs: Event) -> Bool {
    
    let currentDate = NSDate()
    return lhs.startDateInNearestPossibleWeekToDate(currentDate) < rhs.startDateInNearestPossibleWeekToDate(currentDate)
}

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}
