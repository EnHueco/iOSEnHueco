//
//  EventsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import EventKit

class ScheduleManager
{
    private init() {}

    /**
     Returns a schedule with the common free time periods of the users provided.
     */
    class func commonFreeTimePeriodsScheduleForUsers(users:[User]) -> Schedule
    {
        let currentDate = NSDate()
        let commonFreeTimePeriodsSchedule = Schedule()
        
        guard users.count >= 2 else { return commonFreeTimePeriodsSchedule }
        
        for i in 1..<enHueco.appUser.schedule.weekDays.count
        {
            var currentCommonFreeTimePeriods = users.first!.schedule.weekDays[i].events.filter { $0.type == .FreeTime }
            
            for j in 1..<users.count
            {
                var newCommonFreeTimePeriods = [Event]()
                
                for freeTimePeriod1 in currentCommonFreeTimePeriods
                {
                    let startHourInCurrentDate1 = freeTimePeriod1.startHourInDate(currentDate)
                    let endHourInCurrentDate1 = freeTimePeriod1.endHourInDate(currentDate)
                    
                    for freeTimePeriod2 in users[j].schedule.weekDays[i].events.filter({ $0.type == .FreeTime })
                    {
                        let startHourInCurrentDate2 = freeTimePeriod2.startHourInDate(currentDate)
                        let endHourInCurrentDate2 = freeTimePeriod2.endHourInDate(currentDate)
                        
                        if !(endHourInCurrentDate1 < startHourInCurrentDate2 || startHourInCurrentDate1 > endHourInCurrentDate2)
                        {
                            let newStartHour = (startHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? freeTimePeriod1.startHour : freeTimePeriod2.startHour)
                            let newEndHour = (endHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? freeTimePeriod1.endHour : freeTimePeriod2.endHour)
                            
                            newCommonFreeTimePeriods.append(Event(type: .FreeTime, startHour: newStartHour, endHour: newEndHour))
                        }
                    }
                }
                
                currentCommonFreeTimePeriods = newCommonFreeTimePeriods
            }
            
            commonFreeTimePeriodsSchedule.weekDays[i].setEvents(currentCommonFreeTimePeriods)
        }
        
        return commonFreeTimePeriodsSchedule
    }
    
    /**
     Imports an schedule of classes from a device's calendar.
     - parameter generateFreeTimePeriodsBetweenClasses: If gaps between classes should be calculated and added to the schedule.
     */
    class func importScheduleFromCalendar(calendar: EKCalendar, generateFreeTimePeriodsBetweenClasses:Bool) -> Bool
    {
        let today = NSDate()
        let eventStore = EKEventStore()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let componentUnits: NSCalendarUnit = [.Year, .WeekOfYear, .Weekday, .Hour, .Minute, .Second]
        var components = localCalendar.components(componentUnits, fromDate:today)
        
        components.weekday = 6
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let nextFridayAtEndOfDay = localCalendar.dateFromComponents(components)!
        
        components = localCalendar.components(componentUnits, fromDate:today)
        
        components.weekday = 2
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let lastMondayAtStartOfDay = localCalendar.dateFromComponents(components)!
        
        let calendars = [calendar]
        
        let fetchEventsPredicate = eventStore.predicateForEventsWithStartDate(lastMondayAtStartOfDay, endDate: nextFridayAtEndOfDay, calendars: calendars)
        let fetchedEvents = eventStore.eventsMatchingPredicate(fetchEventsPredicate)
        
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        for event in fetchedEvents
        {
            let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: event.startDate)
            
            let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]
            
            let startDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: event.startDate)
            let endDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: event.endDate)
            
            let weekDayDaySchedule = enHueco.appUser.schedule.weekDays[localWeekDayNumber]
            let aClass = Event(type:.Class, name:event.title, startHour: startDateComponents, endHour: endDateComponents, location: event.location)
            
            if weekDayDaySchedule.addEvent(aClass)
            {
                SynchronizationManager.sharedManager().reportNewEvent(aClass)
            }
        }
        
        if generateFreeTimePeriodsBetweenClasses
        {
            //TODO: Calculate Gaps and add them
        }
        return true
    }
}