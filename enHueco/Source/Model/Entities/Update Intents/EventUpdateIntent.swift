//
//  EventUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

struct EventUpdateIntent: MapabbleObject {

    let id: String
    let type: EventType?
    let name: String?
    let startDate: NSDateComponents?
    let endDate: NSDateComponents?
    let location: String?
    let repetitionDays: [Weekday]?

    init(id: String) {
        self.id = id
    }

    func sequence(map: Map) throws {

        typealias JSONKeys = Event.JSONKeys

        type ~> map[JSONKeys.type]
        name ~> map[JSONKeys.name]
        startDate ~> map[JSONKeys.startDate]
        endDate ~> map[JSONKeys.endDate]
        location ~> map[JSONKeys.location]
        repetitionDays ~> map[JSONKeys.repetitionDays]
    }
}