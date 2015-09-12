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
    
    var gaps = [Gap]()
    var classes = [Class]()
    
    init(weekDayName:String)
    {
        self.weekDayName = weekDayName        
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let weekDayName = decoder.decodeObjectForKey("weekDayName") as? String,
            let gaps = decoder.decodeObjectForKey("gaps") as? [Gap],
            let classes = decoder.decodeObjectForKey("classes") as? [Class]
        else
        {
            self.weekDayName = ""
           
            super.init()
            return nil
        }
        
        self.weekDayName = weekDayName
        self.gaps = gaps
        self.classes = classes
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(weekDayName, forKey: "weekDayName")
        coder.encodeObject(gaps, forKey: "gaps")
        coder.encodeObject(classes, forKey: "classes")
    }
}
