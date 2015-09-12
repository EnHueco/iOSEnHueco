//
//  Schedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Schedule: NSObject
{
    let weekDays:[DaySchedule]
    
    override init()
    {
        var weekDays = [DaySchedule]()
        weekDays.append(DaySchedule(weekDayName: ""))
        weekDays.append(DaySchedule(weekDayName: "Domingo"))
        weekDays.append(DaySchedule(weekDayName: "Lunes"))
        weekDays.append(DaySchedule(weekDayName: "Martes"))
        weekDays.append(DaySchedule(weekDayName: "Miércoles"))
        weekDays.append(DaySchedule(weekDayName: "Jueves"))
        weekDays.append(DaySchedule(weekDayName: "Viernes"))
        weekDays.append(DaySchedule(weekDayName: "Sábado"))

        
        self.weekDays = weekDays
    }
}
