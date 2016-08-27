//
//  Schedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

class Schedule: MappableObject {
    
    let events: [Event]
    
    init(map: Map) throws {
        self.events = try [Event](js: map.json)
    }
    
    init(events: [Event]) {
        self.events = events
    }
    
    /// Returns true if event doesn't overlap with any other event, excluding the event with ID == eventToExcludeID.
    func canAddEvent(newEvent: Event, excludingEvent eventToExcludeID: String? = nil) -> Bool {
        
        for event in events where (eventToExcludeID == nil || event.id != eventToExcludeID) && event.overlapsWith(newEvent) {
            return false
        }
        
        return true
    }
}

extension Schedule {
    
    private var instantFreeTimePeriodTTLTimer: NSTimer?
    
    ///Current instant free time period for the day. Self-destroys when the period is over (i.e. currentTime > endHour)
    var instantFreeTimePeriod: Event?
        {
        didSet
        {
            if let instantFreeTimePeriod = instantFreeTimePeriod
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    let currentDate = NSDate()
                    
                    self.instantFreeTimePeriodTTLTimer?.invalidate()
                    self.instantFreeTimePeriodTTLTimer = NSTimer.scheduledTimerWithTimeInterval(instantFreeTimePeriod.endHourInNearestPossibleWeekToDate(currentDate).timeIntervalSinceDate(currentDate), target: self, selector: #selector(Schedule.instantFreeTimePeriodTimeToLiveReached(_:)), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    /// Returns user current free time period, or nil if user is not free.
    func currentFreeTimePeriod() -> Event? {
        
        guard !isInvisible else {
            return nil
        }
        
        if schedule.instantFreeTimePeriod != nil {
            return schedule.instantFreeTimePeriod
        }
        
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        for event in schedule.weekDays[localWeekDayNumber].events where event.type == .FreeTime {
            let startHourInCurrentDate = event.startHourInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endHourInNearestPossibleWeekToDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate) {
                return event
            }
        }
        
        return nil
    }
    
    ///For Performance
    func currentAndNextFreeTimePeriods() -> (currentFreeTimePeriod:Event?, nextFreeTimePeriod:Event?) {
        
        guard !isInvisible else {
            return (nil, nil)
        }
        
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        let localWeekdayEvents = schedule.weekDays[localWeekDayNumber].events
        
        var currentFreeTimePeriod: Event?
        
        for event in localWeekdayEvents where event.type == .FreeTime {
            let startHourInCurrentDate = event.startHourInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endHourInNearestPossibleWeekToDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate) {
                currentFreeTimePeriod = event
            } else if startHourInCurrentDate > currentDate {
                return (currentFreeTimePeriod, event)
            }
        }
        
        return (currentFreeTimePeriod, nil)
    }
    
    /// Returns user's next event
    func nextEvent() -> Event? {
        
        return nil //TODO:
    }
    
    func nextFreeTimePeriod() -> Event? {
        
        guard !isInvisible else {
            return nil
        }
        
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        for event in schedule.weekDays[localWeekDayNumber].events where event.type == .FreeTime && event.startHourInNearestPossibleWeekToDate(currentDate) > currentDate {
            return event
        }
        
        return nil
    }
    
    func instantFreeTimePeriodTimeToLiveReached(timer: NSTimer) {
        instantFreeTimePeriod = nil
    }
    
    func eventWithID(ID: String) -> Event? {
        
        for event in events where event.id == ID {
            return event
        }
        
        return nil
    }
}
