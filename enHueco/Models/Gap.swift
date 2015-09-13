//
//  Gap.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Gap: NSObject, NSCoding
{
    unowned let daySchedule: DaySchedule
    
    let startHour: NSDateComponents
    let endHour: NSDateComponents
    
    init(daySchedule: DaySchedule, startHour: NSDateComponents, endHour: NSDateComponents)
    {
        self.daySchedule = daySchedule
        
        self.startHour = startHour
        self.endHour = endHour
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let daySchedule = decoder.decodeObjectForKey("daySchedule") as? DaySchedule,
            let startHour = decoder.decodeObjectForKey("startHour") as? NSDateComponents,
            let endHour = decoder.decodeObjectForKey("endHour") as? NSDateComponents
        else
        {
            self.daySchedule = DaySchedule(weekDayName: "")
            self.startHour = NSDateComponents()
            self.endHour = NSDateComponents()
            
            super.init()
            return nil
        }
        
        self.daySchedule = daySchedule
        self.startHour = startHour
        self.endHour = endHour
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(startHour, forKey: "startHour")
        coder.encodeObject(endHour, forKey: "endHour")
        coder.encodeObject(daySchedule, forKey: "daySchedule")
    }
    
    //TODO: Implement Equatable protocol
}
