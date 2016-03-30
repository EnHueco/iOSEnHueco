//
//  Schedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

/// A schedule
class Schedule: NSObject, NSCoding
{
    ///DaySchedule array that makes the days of the week
    let weekDays:[DaySchedule]
    
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
                    NSTimer.scheduledTimerWithTimeInterval(instantFreeTimePeriod.endHourInDate(currentDate).timeIntervalSinceDate(currentDate), target: self, selector: #selector(Schedule.instantFreeTimePeriodTimeToLiveReached(_:)), userInfo: nil, repeats: false)
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
}
