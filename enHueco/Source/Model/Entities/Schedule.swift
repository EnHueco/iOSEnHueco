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
    
    /// Returns true if event doesn't overlap with any other event, excluding the event with ID == eventToExcludeID.
    func canAddEvent(newEvent: Event, excludingEvent eventToExcludeID: String? = nil) -> Bool {
        
        let currentDate = NSDate()
        
        let newEventStartHourInCurrentDate = newEvent.startDateInNearestPossibleWeekToDate(currentDate)
        let newEventEndHourInCurrentDate = newEvent.endDateInNearestPossibleWeekToDate(currentDate)
        
        for event in events where eventToExclude == nil || event.id !== eventToExclude.id {
            
            let startHourInCurrentDate = event.startDateInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endDateInNearestPossibleWeekToDate(currentDate)
            
            if !(newEventEndHourInCurrentDate < startHourInCurrentDate || newEventStartHourInCurrentDate > endHourInCurrentDate) {
                return false
            }
        }
        
        return true
    }
    
    /*
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

    override init()
    {
        var weekDays = [DaySchedule]()
        weekDays.append(DaySchedule(weekDayName: ""))
        weekDays.append(DaySchedule(weekDayName: "Sunday".localizedUsingGeneralFile()))
        weekDays.append(DaySchedule(weekDayName: "Monday".localizedUsingGeneralFile()))
        weekDays.append(DaySchedule(weekDayName: "Tuesday".localizedUsingGeneralFile()))
        weekDays.append(DaySchedule(weekDayName: "Wednesday".localizedUsingGeneralFile()))
        weekDays.append(DaySchedule(weekDayName: "Thursday".localizedUsingGeneralFile()))
        weekDays.append(DaySchedule(weekDayName: "Friday".localizedUsingGeneralFile()))
        weekDays.append(DaySchedule(weekDayName: "Saturday".localizedUsingGeneralFile()))
        
        self.weekDays = weekDays
    }
    
    convenience init(JSONEvents: [[String : AnyObject]])
    {
        self.init()
        
        for eventJSON in JSONEvents
        {
            let event = Event(JSONDictionary: eventJSON)
            weekDays[event.localWeekDay()].addEvent(event)
        }
    }
    
    func instantFreeTimePeriodTimeToLiveReached(timer: NSTimer)
    {
        instantFreeTimePeriod = nil
    }
    
    //Mark: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard let weekDays = decoder.decodeObjectForKey("weekDays") as? [DaySchedule] else
        {
            self.weekDays = [DaySchedule]()

            super.init()
            return nil
        }
        
        self.weekDays = weekDays
        
        super.init()
        
        //Ensure didSet is called because we are inside an init method
        ;{ self.instantFreeTimePeriod = decoder.decodeObjectForKey("instantFreeTimePeriod") as? Event }()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(weekDays, forKey: "weekDays")
        coder.encodeObject(instantFreeTimePeriod, forKey: "instantFreeTimePeriod")
    }
    
    func eventAndDayScheduleOfEventWithID(ID: String) -> (event: Event, daySchedule: DaySchedule)?
    {
        for daySchedule in weekDays
        {
            let event = daySchedule.events.filter { $0.ID == ID }.first
            
            if event != nil
            {
                return (event!, daySchedule)
            }
        }
    
        return nil
    }
    
    func removeEventWithID(ID: String) -> Bool
    {
        if let (event, daySchedule) = eventAndDayScheduleOfEventWithID(ID)
        {
            return daySchedule.removeEvent(event)
        }
        
        return false
    }*/
}
