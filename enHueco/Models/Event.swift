//
//  Event.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 9/22/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class Event: NSObject
{
    unowned let daySchedule: DaySchedule
    
    let name:String?
    
    /** UTC weekday, hour and minute time components of the event's start hour */
    let startHour: NSDateComponents
    
    /** UTC weekday, hour and minute time components of the event's end hour */
    let endHour: NSDateComponents
    
    var location: String?
    
    init(daySchedule: DaySchedule, name:String? = nil, startHour: NSDateComponents, endHour: NSDateComponents, location: String? = nil)
    {
        self.daySchedule = daySchedule
        self.name = name
        self.startHour = startHour
        self.endHour = endHour
        
        self.location = location
        
        super.init()
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let daySchedule = decoder.decodeObjectForKey("daySchedule") as? DaySchedule,
            let startHour = decoder.decodeObjectForKey("startHour") as? NSDateComponents,
            let endHour = decoder.decodeObjectForKey("endHour") as? NSDateComponents
            else
        {
            self.name = ""
            self.startHour = NSDateComponents()
            self.endHour = NSDateComponents()
            self.daySchedule = DaySchedule(weekDayName: "")
            
            super.init()
            return nil
        }
        
        self.daySchedule = daySchedule
        self.name = decoder.decodeObjectForKey("name") as? String
        self.startHour = startHour
        self.endHour = endHour
        self.location = decoder.decodeObjectForKey("location") as? String
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(startHour, forKey: "startHour")
        coder.encodeObject(endHour, forKey: "endHour")
        coder.encodeObject(location, forKey: "location")
        coder.encodeObject(daySchedule, forKey: "daySchedule")
    }
    
    /**
        Returns the start hour (Weekday, Hour, Minute) by setting the components to the local date provided,
        but offsetting it to its global UTC Date equivalent.
    */
    func startHourInUTCEquivalentOfLocalDate(date: NSDate) -> NSDate
    {
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!

        var startHourWithDate = globalCalendar.dateBySettingHour(startHour.hour, minute: startHour.minute, second: 0, ofDate: date, options: NSCalendarOptions())!

        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: date)
        let dayOffset = Double(localWeekDayNumber-startHour.weekday)
        startHourWithDate = startHourWithDate.dateByAddingTimeInterval(60*60*24*(-dayOffset))

        return startHourWithDate
    }
    
    /**
        Returns the end hour (Weekday, Hour, Minute) by setting the components to the local date provided,
        but offsetting it to its global UTC Date equivalent.
    */
    func endHourInUTCEquivalentOfLocalDate(date: NSDate) -> NSDate
    {
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        var endHourWithDate = globalCalendar.dateBySettingHour(endHour.hour, minute: endHour.minute, second: 0, ofDate: date, options: NSCalendarOptions())!

        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: date)
        let dayOffset = Double(localWeekDayNumber-endHour.weekday)
        endHourWithDate = endHourWithDate.dateByAddingTimeInterval(60*60*24*(-dayOffset))
        
        return endHourWithDate
    }
    
    //TODO: Implement Equatable protocol
}
