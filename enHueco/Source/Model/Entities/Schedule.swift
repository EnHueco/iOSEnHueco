//
//  Schedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Schedule: NSObject, NSCoding {

    let events: [Event]

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
    }
 */
}
