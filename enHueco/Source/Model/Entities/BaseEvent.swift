//
//  BasicEvent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

enum Weekday: Int {
    case Monday = 0, Tuesday, Wednesday, Thursday, Friday
    case Saturday, Sunday
}

/// The type of the event

enum EventType: String {
    case FreeTime = "FREE_TIME", Class = "CLASS"
}

class BaseEvent: MappableObject {

    struct JSONKeys {
        private init() {}

        static let type = "type"
        static let name = "name"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let location = "location"
        static let repetitionDays = "repetition_days"
    }

    let type: EventType
    let name: String?
    let startDate: NSDate
    let endDate: NSDate
    let location: String?
    let repetitionDays: [Weekday]?

    init(type: EventType, name: String?, location: String?, startDate: NSDate, endDate: NSDate, repetitionDays: [Weekday]?) {

        self.type = type
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.repetitionDays = repetitionDays
    }

    init(map: Map) throws {
        type = try map[JSONKeys.type].fromJson {
            EventType(rawValue: $0)!
        }
        name = try? map.extract(JSONKeys.name)
        // To do: Set start & end dates based on JSON data
        location = try? map.extract(JSONKeys.location)
        repetitionDays = try map.extract(JSONKeys.repetitionDays)
    }
}
