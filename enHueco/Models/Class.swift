//
//  Class.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Class: NSObject
{
    unowned let daySchedule: DaySchedule

    let name:String?
    let startHour: NSDateComponents
    let endHour: NSDateComponents
    
    var location: String?
    
    init(daySchedule: DaySchedule, name:String?, startHour: NSDateComponents, endHour: NSDateComponents, location: String? = nil)
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
    
    //TODO: Implement Equatable protocol
}
