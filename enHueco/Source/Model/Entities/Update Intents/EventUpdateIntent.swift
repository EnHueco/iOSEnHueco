//
//  EventUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

struct EventUpdateIntent: MappableBase {

    var id: String
    var type: EventType?
    var name: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var location: String?
    var repeating: Bool?
    
    init(id: String) {
        self.id = id
    }
    
    init(valuesOfEvent event: Event) {
        
        self.init(id: event.id)

        type = event.type
        name = event.name
        location = event.location
        startDate = event.startDate
        endDate = event.endDate
        location = event.location
        repeating = event.repeating
    }
    
    static func newInstance(json: Json, context: Context) throws -> EventUpdateIntent {
        throw GenericError.UnsupportedOperation
    }

    func sequence(map: Map) throws {

        typealias JSONKeys = BaseEvent.JSONKeys

        try type ~> map[.Key(JSONKeys.type)]
        try name ~> map[.Key(JSONKeys.name)]
        try startDate ~> map[.Key(JSONKeys.startDate)]
        try endDate ~> map[.Key(JSONKeys.endDate)]
        try location ~> map[.Key(JSONKeys.location)]
        try repeating ~> map[.Key(JSONKeys.repeating)]
    }
}