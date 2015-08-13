//
//  Gap.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Gap: NSObject
{
    var startHour: NSDateComponents
    var endHour: NSDateComponents
    
    init(startHour: NSDateComponents, endHour: NSDateComponents)
    {
        self.startHour = startHour
        self.endHour = endHour
    }
}
