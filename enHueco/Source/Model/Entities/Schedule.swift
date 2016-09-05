//
//  Schedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

class Schedule: MappableObject, Equatable {
    
    let events: [Event]
    
    var privacySettings = try! PrivacySettings() // Temporary ! We have to initialize this correctly
    
    required init(map: Map) throws {
        events = try [Event](js: map.json).sort(<)
    }
    
    init(events: [Event]) {
        self.events = events.sort(<)
    }
    
    static func newInstance(json: Json, context: Context) throws -> Self {
        let map = Map(json: json, context: context)
        let new = try self.init(map: map)
        return new
    }
    
    /// Returns true if event doesn't overlap with any other event, excluding the event with ID == eventToExcludeID.
    func canAddEvent(newEvent: BaseEvent, excludingEvent eventToExcludeID: String? = nil) -> Bool {
        
        for event in events where (eventToExcludeID == nil || event.id != eventToExcludeID) && event.overlapsWith(newEvent) {
            return false
        }
        
        return true
    }

    func eventWithID(ID: String) -> Event? {

        for event in events where event.id == ID {
            return event
        }

        return nil
    }
    
    func eventsInDayOfDate(date: NSDate) -> [Event] {
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        return events.filter {
            return localCalendar.isDate($0.startDateInNearestPossibleWeekToDate(date), inSameDayAsDate: date)
        }
    }
    
    /// Returns the current and the next free time periods for the user
    func currentAndNextFreeTimePeriods() -> (currentFreeTimePeriod:Event?, nextFreeTimePeriod:Event?) {
        
        guard !privacySettings.invisible else { return (nil, nil) }
        
        let currentDate = NSDate()
        var currentFreeTimePeriod: Event?
        
        for event in events where event.type == .FreeTime {
            let startHourInCurrentDate = event.startDateInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endDateInNearestPossibleWeekToDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate) {
                currentFreeTimePeriod = event
            } else if startHourInCurrentDate > currentDate {
                return (currentFreeTimePeriod, event)
            }
        }
        
        return (currentFreeTimePeriod, nil)
    }
    
    /// Returns the user's next event
    func nextEvent() -> Event? {
        
        guard !privacySettings.invisible else { return nil }
        
        let currentDate = NSDate()
        
        for event in events where event.startDateInNearestPossibleWeekToDate(currentDate) > currentDate {
            return event
        }
        
        return nil
    }
    
    /** Returns the common free time periods among the schedules provided and this one
     Note: **Only works with repeating days for now**
     */
    func commonFreeTimePeriodsScheduleAmong(schedules: [Schedule]) -> Schedule {
        
        let currentDate = NSDate()
        var commonFreeTimePeriods = [BaseEvent]()
        
        guard schedules.count >= 2 else {
            return Schedule(events: [])
        }
        
        for event in (events.filter { $0.type == .FreeTime }) {
            
            let startHourInCurrentDate = event.startDateInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endDateInNearestPossibleWeekToDate(currentDate)
            
            for friendSchedule in schedules {
                for friendEvent in (friendSchedule.events.filter { $0.type == .FreeTime }) where friendEvent.overlapsWith(event) {
                    
                    let friendStartHourInCurrentDate = friendEvent.startDateInNearestPossibleWeekToDate(currentDate)
                    let friendEndHourInCurrentDate = friendEvent.endDateInNearestPossibleWeekToDate(currentDate)
                    
                    let newStartDate = (startHourInCurrentDate.isBetween(friendStartHourInCurrentDate, and: friendEndHourInCurrentDate) ? event.startDate : friendEvent.startDate)
                    let newEndDate = (endHourInCurrentDate.isBetween(friendStartHourInCurrentDate, and: friendEndHourInCurrentDate) ? event.endDate : friendEvent.endDate)
                    
                    let commonEvent = BaseEvent(type: .FreeTime, name: nil, location: nil, startDate: newStartDate, endDate: newEndDate, repeating: true)
                    commonFreeTimePeriods.append(commonEvent)
                }
            }
        }
        
        return Schedule(events: commonFreeTimePeriods)
    }
}

func == (lhs: Schedule, rhs: Schedule) -> Bool {
    return lhs.events == rhs.events
}

extension Schedule {

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
    }*/
    
    /*
    func instantFreeTimePeriodTimeToLiveReached(timer: NSTimer) {
        instantFreeTimePeriod = nil
    }*/
}
