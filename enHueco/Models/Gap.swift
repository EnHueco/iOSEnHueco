//
//  Gap.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Gap: Event
{
    override init(daySchedule: DaySchedule, name:String? = "Hueco", startHour: NSDateComponents, endHour: NSDateComponents, location: String? = nil)
    {
        super.init(daySchedule: daySchedule, name: name ?? "Hueco", startHour: startHour, endHour: endHour, location: location)
    }
    
    required init?(coder decoder: NSCoder)
    {
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        super.encodeWithCoder(coder)
    }
}
