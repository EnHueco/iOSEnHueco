//
//  Event.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 9/22/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

enum EventType: String
{
    case FreeTime = "FREE_TIME", Class = "CLASS"
}

class Event: EHSynchronizable, Comparable, NSCopying
{
    weak var daySchedule: DaySchedule!
    
    var name:String?
    {
        didSet
        {
            if name == "" { name = nil }
        }
    }
    
    var location: String?
    {
        didSet
        {
            if location == "" { location = nil }
        }
    }

    var type: EventType
    
    /** UTC weekday, hour and minute time components of the event's start hour */
    var startHour: NSDateComponents
    
    /** UTC weekday, hour and minute time components of the event's end hour */
    var endHour: NSDateComponents
    
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
            let daySchedule = decoder.decodeObjectForKey("daySchedule") as? DaySchedule,
            let type = decoder.decodeObjectForKey("type") as? String,
            let startHour = decoder.decodeObjectForKey("startHour") as? NSDateComponents,
            let endHour = decoder.decodeObjectForKey("endHour") as? NSDateComponents
        else
        {
            self.type = .FreeTime
            self.startHour = NSDateComponents()
            self.endHour = NSDateComponents()
            self.daySchedule = DaySchedule(weekDayName: "")
        
            super.init(coder: decoder)
            return nil
        }
        
        self.type = EventType(rawValue: type)!
        self.daySchedule = daySchedule
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
    
    func replaceValuesWithThoseOfTheEvent(event: Event)
    {
        name = event.name
        type = event.type
        startHour = event.startHour
        endHour = event.endHour
        location = event.location
        daySchedule = event.daySchedule
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(type.rawValue, forKey: "type")
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(startHour, forKey: "startHour")
        coder.encodeObject(endHour, forKey: "endHour")
        coder.encodeObject(location, forKey: "location")
        coder.encodeObject(daySchedule, forKey: "daySchedule")
        
        super.encodeWithCoder(coder)
    }
    
    /// Returns the start hour (Weekday, Hour, Minute) by setting the components to the date provided.
    func startHourInDate(date: NSDate) -> NSDate
    {
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let components = NSDateComponents()
        components.year = globalCalendar.component(.Year, fromDate: date)
        components.month = globalCalendar.component(.Month, fromDate: date)
        components.weekOfMonth = globalCalendar.component(.WeekOfMonth, fromDate: date)
        components.weekday = startHour.weekday
        components.hour = startHour.hour
        components.minute = startHour.minute
        components.second = 0

        return globalCalendar.dateFromComponents(components)!
    }
    
    /// Returns the end hour (Weekday, Hour, Minute) by setting the components to the date provided.
    func endHourInDate(date: NSDate) -> NSDate
    {
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let components = NSDateComponents()
        components.year = globalCalendar.component(.Year, fromDate: date)
        components.month = globalCalendar.component(.Month, fromDate: date)
        components.weekOfMonth = globalCalendar.component(.WeekOfMonth, fromDate: date)
        components.weekday = endHour.weekday
        components.hour = endHour.hour
        components.minute = endHour.minute
        components.second = 0
        
        return globalCalendar.dateFromComponents(components)!
    }
    
    func toJSONObject (associatingUser user: User? = nil) -> [String : AnyObject]
    {
        var dictionary = [String:AnyObject]()
        
        dictionary["type"] = type.rawValue
        
        if name != nil { dictionary["name"] = name }
        if location != nil { dictionary["location"] = location }
        
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
        
        let startHourWeekDayConversionComponents = NSDateComponents()
        startHourWeekDayConversionComponents.year = globalCalendar.component(.Year, fromDate: currentDate)
        startHourWeekDayConversionComponents.month = globalCalendar.component(.Month, fromDate: currentDate)
        startHourWeekDayConversionComponents.weekOfMonth = globalCalendar.component(.WeekOfMonth, fromDate: currentDate)
        startHourWeekDayConversionComponents.weekday = self.startHour.weekday
        startHourWeekDayConversionComponents.hour = self.startHour.hour
        startHourWeekDayConversionComponents.minute = self.startHour.minute
        startHourWeekDayConversionComponents.second = 0
        
        let startHourInDate = globalCalendar.dateFromComponents(startHourWeekDayConversionComponents)!
        return localCalendar.component(NSCalendarUnit.Weekday, fromDate: startHourInDate)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let event = Event(type: type, name: name, startHour: startHour, endHour: endHour, location: location, ID: ID, lastUpdatedOn: lastUpdatedOn)
        event.daySchedule = daySchedule
        
        return event
    }
}

func < (lhs: Event, rhs: Event) -> Bool
{
    let currentDate = NSDate()
    return lhs.startHourInDate(currentDate) < rhs.startHourInDate(currentDate)
}

func == (lhs: Event, rhs: Event) -> Bool
{
    let currentDate = NSDate()
    return lhs.startHourInDate(currentDate).hasSameWeekdayHourAndMinutesThan(rhs.startHourInDate(currentDate)) && lhs.endHourInDate(currentDate).hasSameWeekdayHourAndMinutesThan(rhs.endHourInDate(currentDate))
}
