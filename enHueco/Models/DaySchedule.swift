//
//  DaySchedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class DaySchedule: NSObject
{
    let weekDayName: String
    
    var gaps = [Gap]()
    var classes = [Class]()
    
    init(weekDayName:String, gaps:[Gap], classes:[Class] = [Class]())
    {
        self.weekDayName = weekDayName
        
        self.classes = classes
    }
}
