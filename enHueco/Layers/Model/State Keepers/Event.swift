//
//  Event.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 9/22/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import Genome
/// The type of the event
enum EventType: String
{
    case FreeTime = "FREE_TIME", Class = "CLASS"
}

/// A calendar event (class or free time at the moment)
class Event
{
    let userID: String
    
    let eventID: String

    let type: EventType
    
    let name: String
    
    let startDate: NSDateComponents
    
    let endDate: NSDateComponents
    
    let location: String
    
    let repetitionDays: String
    
    
    init(map: Map) throws {
        userID = try map.extract("user_id")
        eventID = try map.extract("event_id")
        type = try map["type"].fromJson { EventType(rawValue: $0)! }
        name = try map.extract("name")
        // To do: Set start & end dates based on JSON data
        location = try map.extract("location")
        repetitionDays = try map.extract("repetition_days")
        
    }
    
    /*
    init(type:EventType, name:String? = nil, startHour: NSDateComponents, endHour: NSDateComponents, location: String? = nil, ID: String? = nil, lastUpdatedOn : NSDate = NSDate())
    {
        self.type = type
        self.name = name
        self.startHour = startHour
        self.endHour = endHour
        
        self.location = location
        
        super.init(ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
        
    required init?(coder decoder: NSCoder)
    {
        guard
            let type = decoder.decodeObjectForKey("type") as? String,
            let startHour = decoder.decodeObjectForKey("startHour") as? NSDateComponents,
            let endHour = decoder.decodeObjectForKey("endHour") as? NSDateComponents
        else
        {
            return nil
        }
        
        self.type = EventType(rawValue: type)!
        self.startHour = startHour
        self.endHour = endHour
        
        self.name = decoder.decodeObjectForKey("name") as? String
        self.location = decoder.decodeObjectForKey("location") as? String
        
        super.init(coder: decoder)
    }
    
    convenience init(JSONDictionary: [String : AnyObject])
    {
        let ID = String(JSONDictionary["id"] as! Int)
        let lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
        
        let type = JSONDictionary["type"] as! String
        let name = JSONDictionary["name"] as? String
        let location = JSONDictionary ["location"] as? String
        
        let startHourWeekDay = Int(JSONDictionary ["start_hour_weekday"] as! String)!
        let startHourStringComponents = (JSONDictionary["start_hour"] as! String).componentsSeparatedByString(":")
        let startHour = Int(startHourStringComponents[0])!
        let startMinute = Int(startHourStringComponents[1])!
        
        let endHourWeekDay = Int(JSONDictionary ["end_hour_weekday"] as! String)!
        let endHourStringComponents = (JSONDictionary["end_hour"] as! String).componentsSeparatedByString(":")
        let endHour = Int(endHourStringComponents[0])!
        let endMinute = Int(endHourStringComponents[1])!
        
        let startHourComponents = NSDateComponents(weekday: startHourWeekDay, hour: startHour, minute: startMinute)
        let endHourComponents = NSDateComponents(weekday: endHourWeekDay, hour: endHour, minute: endMinute)
        
        self.init(type: EventType(rawValue: type)!, name: name, startHour: startHourComponents, endHour: endHourComponents, location: location, ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    convenience init(instantFreeTimeJSONDictionary: [String : AnyObject])
    {
        let name = instantFreeTimeJSONDictionary["name"] as? String
        let location = instantFreeTimeJSONDictionary ["location"] as? String
        
        let endDate = NSDate(serverFormattedString: instantFreeTimeJSONDictionary["valid_until"] as! String)!
        
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!

        let endHourComponents = globalCalendar.components([.Weekday, .Hour, .Minute], fromDate: endDate)
        
        self.init(type: .FreeTime, name: name, startHour: NSDateComponents(), endHour: endHourComponents, location: location, ID: "", lastUpdatedOn: NSDate())
    }
    
    func replaceValuesWithThoseOfTheEvent(event: Event)
    {
        name = event.name
        type = event.type
        startHour = event.startHour
        endHour = event.endHour
        location = event.location
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(type.rawValue, forKey: "type")
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(startHour, forKey: "startHour")
        coder.encodeObject(endHour, forKey: "endHour")
        coder.encodeObject(location, forKey: "location")
        
        super.encodeWithCoder(coder)
    }
    
    /** Returns the start hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     */
    func startHourInNearestPossibleWeekToDate(date: NSDate) -> NSDate
    {
        return eventComponents(startHour, inNearestPossibleWeekToDate: date)
    }
    
    /** Returns the end hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     */
    func endHourInNearestPossibleWeekToDate(date: NSDate) -> NSDate
    {
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!

        var endHourDate = eventComponents(endHour, inNearestPossibleWeekToDate: date)
        
        if endHourDate < startHourInNearestPossibleWeekToDate(date) {
            endHourDate = globalCalendar.dateByAddingUnit(.WeekOfMonth, value: 1, toDate: endHourDate, options: [])!
        }
        
        return endHourDate
    }
    
    /** Returns a date by setting the components (Weekday, Hour, Minute) provided to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     */
    private func eventComponents(eventComponents: NSDateComponents, inNearestPossibleWeekToDate date: NSDate) -> NSDate
    {
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        var startOfWeek: NSDate?
        var interval = NSTimeInterval(0)
        
        globalCalendar.rangeOfUnit(.WeekOfMonth, startDate: &startOfWeek, interval: &interval, forDate: date)
        
        let componentsToAdd = NSDateComponents()
        componentsToAdd.day = eventComponents.weekday-1
        componentsToAdd.hour = eventComponents.hour
        componentsToAdd.minute = eventComponents.minute
        
        return globalCalendar.dateByAddingComponents(componentsToAdd, toDate: startOfWeek!, options: [])!
    }
    
    func toJSONObject (associatingUser user: User? = nil) -> [String : AnyObject]
    {
        var dictionary = [String:AnyObject]()
        
        dictionary["type"] = type.rawValue
        
        dictionary["name"] = name
        dictionary["location"] = location
        
        dictionary["start_hour_weekday"] = String(startHour.weekday)
        dictionary["end_hour_weekday"] = String(endHour.weekday)
        dictionary["start_hour"] = "\(startHour.hour):\(startHour.minute)"
        dictionary["end_hour"] = "\(endHour.hour):\(endHour.minute)"
        
        if user != nil
        {
            dictionary["user"] = user!.username
        }
        
        return dictionary
    }
    
    func localWeekDay() -> Int
    {
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let startHourWeekDayConversionComponents = globalCalendar.components([.Year, .Month, .WeekOfMonth], fromDate: currentDate)
        startHourWeekDayConversionComponents.weekday = startHour.weekday
        startHourWeekDayConversionComponents.hour = startHour.hour
        startHourWeekDayConversionComponents.minute = startHour.minute
        
        let startHourInNearestPossibleWeekToDate = globalCalendar.dateFromComponents(startHourWeekDayConversionComponents)!
        return localCalendar.component(NSCalendarUnit.Weekday, fromDate: startHourInNearestPossibleWeekToDate)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let event = Event(type: type, name: name, startHour: startHour, endHour: endHour, location: location, ID: ID, lastUpdatedOn: lastUpdatedOn)        
        return event
    }
     
     
     /// Returns true if event doesn't overlap with any gap or class, excluding eventToExclude.
     func canAddEvent(newEvent: Event, excludingEvent eventToExclude:Event? = nil) -> Bool
     {
     let currentDate = NSDate()
     
     let newEventStartHourInCurrentDate = newEvent.startHourInNearestPossibleWeekToDate(currentDate)
     let newEventEndHourInCurrentDate = newEvent.endHourInNearestPossibleWeekToDate(currentDate)
     
     for event in mutableEvents where eventToExclude == nil || event !== eventToExclude
     {
     let startHourInCurrentDate = event.startHourInNearestPossibleWeekToDate(currentDate)
     let endHourInCurrentDate = event.endHourInNearestPossibleWeekToDate(currentDate)
     
     if !(newEventEndHourInCurrentDate < startHourInCurrentDate || newEventStartHourInCurrentDate > endHourInCurrentDate)
     {
     return false
     }
     }
     
     return true
     }
     
     func eventWithStartHour(startHour: NSDateComponents) -> Event?
     {
     return mutableEvents.filter { $0.startHour == startHour }.first
     }
     
     
*/
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