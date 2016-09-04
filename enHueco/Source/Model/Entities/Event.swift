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

class Event: BaseEvent {

    struct JSONKeys {
        private init() {}

        static let userID = "user_id"
        static let id = "id"
    }

    let userID: String
    let id: String

    required init(map: Map) throws {
        userID = try map.extract(.Key(JSONKeys.userID))
        id = try map.extract(.Key(JSONKeys.id))

        try super.init(map: map)
    }
}

func < (lhs: Event, rhs: Event) -> Bool {
    
    let currentDate = NSDate()
    return lhs.startDateInNearestPossibleWeekToDate(currentDate) < rhs.startDateInNearestPossibleWeekToDate(currentDate)
}

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}
