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
    let repetitionDays: Set<Weekday>?

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
    
    /** Returns the start hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     
     If the event is unique (i.e. non-repeating), the startDate is returned unchanged.
     */
    func startDateInNearestPossibleWeekToDate(date: NSDate) -> NSDate
    {
        guard repetitionDays != nil else { return startDate }
        
        return date(startDate, inNearestPossibleWeekToDate: date)
    }
    
    /** Returns the end hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     
     If the event is unique (i.e. non-repeating), the endDate is returned unchanged.
     */
    func endDateInNearestPossibleWeekToDate(date: NSDate) -> NSDate
    {
        guard repetitionDays != nil else { return endDate }
        
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        var endHourDate = date(endDate, inNearestPossibleWeekToDate: date)
        
        if endHourDate < startDateInNearestPossibleWeekToDate(date) {
            endHourDate = globalCalendar.dateByAddingUnit(.WeekOfMonth, value: 1, toDate: endHourDate, options: [])!
        }
        
        return endHourDate
    }
    
    /** Returns a date by setting the components (Weekday, Hour, Minute) provided to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     */
    private func date(date: NSDate, inNearestPossibleWeekToDate targetDate: NSDate) -> NSDate
    {
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let eventComponents = globalCalendar.components([.Weekday, .Hour, .Minute], fromDate: date)
        
        var startOfWeek: NSDate?
        
        globalCalendar.rangeOfUnit(.WeekOfMonth, startDate: &startOfWeek, interval: nil, forDate: targetDate)
        
        let componentsToAdd = NSDateComponents()
        componentsToAdd.day = eventComponents.weekday-1
        componentsToAdd.hour = eventComponents.hour
        componentsToAdd.minute = eventComponents.minute
        
        return globalCalendar.dateByAddingComponents(componentsToAdd, toDate: startOfWeek!, options: [])!
    }
    
    /// Returns true iff the event overlaps with another. (Note: **Only works for repeating events for now**)
    func eventOverlapsWith(anotherEvent: Event) -> Bool {
        
        let currentDate = NSDate()
        
        let anotherEventStartHourInCurrentDate = anotherEvent.startDateInNearestPossibleWeekToDate(currentDate)
        let anotherEventEndHourInCurrentDate = anotherEvent.endDateInNearestPossibleWeekToDate(currentDate)
        
        let startHourInCurrentDate = startDateInNearestPossibleWeekToDate(currentDate)
        let endHourInCurrentDate = endDateInNearestPossibleWeekToDate(currentDate)
            
        if !(newEventEndHourInCurrentDate < startHourInCurrentDate || newEventStartHourInCurrentDate > endHourInCurrentDate) {
            
            // Times overlap, let's check if any days are equal
            for repetitionDay in event.repetitionDays ?? [] where (newEvent.repetitionDays ?? []).contains(repetitionDay) {
                return true
            }
        }
        
        return false
    }
}
