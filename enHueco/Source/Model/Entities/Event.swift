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

    override init(map: Map) throws {
        userID = try map.extract(JSONKeys.eventID)
        eventID = try map.extract("id")

        super.init(map: Map)
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
}

/*
func < (lhs: Event, rhs: Event) -> Bool
{
    let currentDate = NSDate()
    return lhs.startHourInNearestPossibleWeekToDate(currentDate) < rhs.startHourInNearestPossibleWeekToDate(currentDate)
}

func == (lhs: Event, rhs: Event) -> Bool
{
    let currentDate = NSDate()
    return lhs.startHourInNearestPossibleWeekToDate(currentDate).hasSameWeekdayHourAndMinutesThan(rhs.startHourInNearestPossibleWeekToDate(currentDate)) && lhs.endHourInNearestPossibleWeekToDate(currentDate).hasSameWeekdayHourAndMinutesThan(rhs.endHourInNearestPossibleWeekToDate(currentDate))
}
*/