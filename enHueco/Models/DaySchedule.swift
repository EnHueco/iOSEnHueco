//
//  DaySchedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class DaySchedule: NSObject, NSCoding
{
    let weekDayName: String
    
    private var mutableEvents = [Event]()
    
    var events:[Event]
    {
        get
        {
            return mutableEvents
        }
    }
    
    init(weekDayName:String)
    {
        self.weekDayName = weekDayName        
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let weekDayName = decoder.decodeObjectForKey("weekDayName") as? String,
            let mutableEvents = decoder.decodeObjectForKey("mutableEvents") as? [Event]
        else
        {
            self.weekDayName = ""
           
            super.init()
            return nil
        }
        
        self.weekDayName = weekDayName
        self.mutableEvents = mutableEvents
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(weekDayName, forKey: "weekDayName")
        coder.encodeObject(mutableEvents, forKey: "mutableEvents")
    }
    
    func setEvents(events: [Event])
    {
        for event in events
        {
            event.daySchedule = self
        }
        
        mutableEvents = events
    }
   
    /// Returns true if event doesn't overlap with any gap or class, excluding eventToExclude.
    func canAddEvent(newEvent: Event, excludingEvent eventToExclude:Event? = nil) -> Bool
    {
        let currentDate = NSDate()
        
        let newEventStartHourInCurrentDate = newEvent.startHourInDate(currentDate)
        let newEventEndHourInCurrentDate = newEvent.endHourInDate(currentDate)
        
        for event in mutableEvents where eventToExclude == nil || event !== eventToExclude
        {
            let startHourInCurrentDate = event.startHourInDate(currentDate)
            let endHourInCurrentDate = event.endHourInDate(currentDate)
            
            if !(newEventEndHourInCurrentDate < startHourInCurrentDate || newEventStartHourInCurrentDate > endHourInCurrentDate)
            {
                return false
            }
        }
        
        return true
    }
    
    /**
    **Caution** Adds the events with no checks for overlapping or notifications to the server.
    Should **only** be used during initialization.
    */
    func _addEventForInitialization(newEvent: Event)
    {
        newEvent.daySchedule = self
        mutableEvents.append(newEvent)
    }
    
    /// Adds event if it doesn't overlap with any other event
    func addEvent(newEvent: Event) -> Bool
    {
        if canAddEvent(newEvent)
        {
            newEvent.daySchedule = self
            mutableEvents.append(newEvent)
            
            SynchronizationManager.sharedManager().reportNewEvent(newEvent)
                        
            return true
        }
        return false
    }
    
    /**
        Adds all events if they don't overlap with any other event. The new events *must* not overlap with themselves, otherwise the method will not be
        able to add them all.
        
        - returns: True if all events could be added correctly
    */
    func addEvents(newEvents: [Event]) -> Bool
    {
        for newEvent in newEvents
        {
            if !addEvent(newEvent) { return false }
        }
        return true
    }
    
    func removeEvent(event: Event) -> Bool
    {
        return mutableEvents.removeObject(event)
    }
    
    func eventWithStartHour(startHour: NSDateComponents) -> Event?
    {
        for event in mutableEvents where event.startHour == startHour
        {
            return event
        }
        return nil
    }
    
    // TODO: Implement Equatable protocol
}
