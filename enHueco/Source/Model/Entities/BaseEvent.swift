//
//  BasicEvent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

/// The type of the event

enum EventType: String, NodeConvertible {
    case FreeTime = "FREE_TIME", Class = "CLASS"
}

class BaseEvent: MappableObject {

    struct JSONKeys {
        fileprivate init() {}

        static let type = "type"
        static let name = "name"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let location = "location"
        static let repeating = "repeating"
    }

    let type: EventType
    let name: String?
    let startDate: Date
    let endDate: Date
    let location: String?
    let repeating: Bool

    init(type: EventType, name: String?, location: String?, startDate: Date, endDate: Date, repeating: Bool) {

        self.type = type
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.repeating = repeating
    }

    required init(map: Map) throws {
        
        type = try map.extract(JSONKeys.type)
        name = try? map.extract(JSONKeys.name)
        startDate = try map.extract(JSONKeys.startDate)
        endDate = try map.extract(JSONKeys.endDate)
        location = try? map.extract(JSONKeys.location)
        repeating = try map.extract(JSONKeys.repeating)
    }
    
//    static func newInstance(_ json: Json, context: Context) throws -> Self {
//        let map = Map(json: json, context: context)
//        let new = try self.init(map: map)
//        try new.sequence(map)
//        return new
//    }

    func sequence(_ map: Map) throws {
        
        typealias JSONKeys = BaseEvent.JSONKeys
        
        try type ~> map[JSONKeys.type]
        try name ~> map[JSONKeys.name]
        try startDate ~> map[JSONKeys.startDate]
        try endDate ~> map[JSONKeys.endDate]
        try location ~> map[JSONKeys.location]
        try repeating ~> map[JSONKeys.repeating]
    }
    
    /** Returns the start hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     
     If the event is unique (i.e. non-repeating), the startDate is returned unchanged.
     */
    func startDateInNearestPossibleWeekToDate(_ targetDate: Date) -> Date  {

        guard repeating else { return startDate }
        return date(startDate, inNearestPossibleWeekToDate: targetDate)
    }
    
    /** Returns the end hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     
     If the event is unique (i.e. non-repeating), the endDate is returned unchanged.
     */
    func endDateInNearestPossibleWeekToDate(_ targetDate: Date) -> Date  {

        guard repeating else { return endDate }
        
        var globalCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        globalCalendar.timeZone = TimeZone(identifier: "UTC")!
        
        var endHourDate = date(endDate, inNearestPossibleWeekToDate: targetDate)
        
        if endHourDate < startDateInNearestPossibleWeekToDate(targetDate) {
            endHourDate = (globalCalendar as NSCalendar).date(byAdding: .weekOfMonth, value: 1, to: endHourDate, options: [])!
        }
        
        return endHourDate
    }
    
    /** Returns a date by setting the components (Weekday, Hour, Minute) provided to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     */
    fileprivate func date(_ date: Date, inNearestPossibleWeekToDate targetDate: Date) -> Date  {

        var globalCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        globalCalendar.timeZone = TimeZone(identifier: "UTC")!
        
        let eventComponents = (globalCalendar as NSCalendar).components([.weekday, .hour, .minute], from: date)
        
        var startOfWeek: NSDate?
        
        (globalCalendar as NSCalendar).range(of: .weekOfMonth, start: &startOfWeek, interval: nil, for: targetDate)
        
        var componentsToAdd = DateComponents()
        componentsToAdd.day = eventComponents.weekday!-1
        componentsToAdd.hour = eventComponents.hour
        componentsToAdd.minute = eventComponents.minute
        
        return (globalCalendar as NSCalendar).date(byAdding: componentsToAdd, to: startOfWeek! as Date, options: [])!
    }
    
    /// Returns true iff the event overlaps with another.
    func overlapsWith(_ anotherEvent: BaseEvent) -> Bool {
        
        let currentDate = Date()
        
        let anotherEventStartHourInCurrentDate = anotherEvent.startDateInNearestPossibleWeekToDate(currentDate)
        let anotherEventEndHourInCurrentDate = anotherEvent.endDateInNearestPossibleWeekToDate(currentDate)
        
        let startHourInCurrentDate = startDateInNearestPossibleWeekToDate(currentDate)
        let endHourInCurrentDate = endDateInNearestPossibleWeekToDate(currentDate)
            
        return !(anotherEventEndHourInCurrentDate < startHourInCurrentDate || anotherEventStartHourInCurrentDate > endHourInCurrentDate)
    }
}
