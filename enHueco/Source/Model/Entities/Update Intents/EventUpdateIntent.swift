//
//  EventUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

struct EventUpdateIntent: MappableBase {

    var id: String
    var type: EventType?
    var name: String?
    var startDate: Date?
    var endDate: Date?
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
        startDate = event.startDate as Date
        endDate = event.endDate as Date
        location = event.location
        repeating = event.repeating
    }
    
    init(node: Node, in context: Context) throws {
        throw GenericError.unsupportedOperation
    }

    func sequence(_ map: Map) throws {

        typealias JSONKeys = BaseEvent.JSONKeys

        try type ~> map[JSONKeys.type]
        try name ~> map[JSONKeys.name]
        try startDate ~> map[JSONKeys.startDate]
        try endDate ~> map[JSONKeys.endDate]
        try location ~> map[JSONKeys.location]
        try repeating ~> map[JSONKeys.repeating]
    }
}
