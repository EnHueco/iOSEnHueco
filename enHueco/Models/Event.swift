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
    case Gap = "GAP", Class = "CLASS"
}

class Event: NSObject, NSCoding, Comparable
{
    weak var daySchedule: DaySchedule!
    
    let name:String?
    
    let type: EventType
    
    /** UTC weekday, hour and minute time components of the event's start hour */
    let startHour: NSDateComponents
    
    /** UTC weekday, hour and minute time components of the event's end hour */
    let endHour: NSDateComponents
    
    var location: String?
    
    init(type:EventType, name:String? = nil, startHour: NSDateComponents, endHour: NSDateComponents, location: String? = nil)
    {
        self.type = type
        self.name = name ?? (type == .Gap ? "Hueco" : "Clase")
        self.startHour = startHour
        self.endHour = endHour
        
        self.location = location
        
        super.init()
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
            self.type = .Gap
            self.name = ""
            self.startHour = NSDateComponents()
            self.endHour = NSDateComponents()
            self.daySchedule = DaySchedule(weekDayName: "")
            
            super.init()
            return nil
        }
        
        self.type = EventType(rawValue: type)!
        self.daySchedule = daySchedule
        self.name = decoder.decodeObjectForKey("name") as? String
        self.startHour = startHour
        self.endHour = endHour
        self.location = decoder.decodeObjectForKey("location") as? String
        
        super.init()
    }
    
    convenience init(JSONDictionary: [String : AnyObject])
    {
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
        
        self.init(type: EventType(rawValue: type)!, name: name, startHour: startHourComponents, endHour: endHourComponents, location: location)
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(type.rawValue, forKey: "type")
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(startHour, forKey: "startHour")
        coder.encodeObject(endHour, forKey: "endHour")
        coder.encodeObject(location, forKey: "location")
        coder.encodeObject(daySchedule, forKey: "daySchedule")
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
    
    func toJSONObject () -> [String : AnyObject]
    {
        var dictionary = [String:AnyObject]()
        
        dictionary["type"] = type.rawValue
        dictionary["start_hour_weekday"] = String(startHour.weekday)
        dictionary["end_hour_weekday"] = String(endHour.weekday)
        dictionary["start_hour"] = "\(startHour.hour):\(startHour.minute)"
        dictionary["end_hour"] = "\(endHour.hour):\(endHour.minute)"
        
        return dictionary
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
