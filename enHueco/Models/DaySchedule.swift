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
    
    private var mutableGaps = [Gap]()
    private var mutableClasses = [Class]()
    
    var gaps:[Gap]
    {
        get
        {
            return mutableGaps
        }
    }
    
    var classes:[Class]
    {
        get
        {
            return mutableClasses
        }
    }

    
    init(weekDayName:String)
    {
        self.weekDayName = weekDayName        
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let weekDayName = decoder.decodeObjectForKey("weekDayName") as? String,
            let mutableGaps = decoder.decodeObjectForKey("mutableGaps") as? [Gap],
            let mutableClasses = decoder.decodeObjectForKey("mutableClasses") as? [Class]
        else
        {
            self.weekDayName = ""
           
            super.init()
            return nil
        }
        
        self.weekDayName = weekDayName
        self.mutableGaps = mutableGaps
        self.mutableClasses = mutableClasses
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(weekDayName, forKey: "weekDayName")
        coder.encodeObject(mutableGaps, forKey: "mutableGaps")
        coder.encodeObject(mutableClasses, forKey: "mutableGaps")
    }
    
    func setGaps(gaps: [Gap])
    {
        mutableGaps = gaps
    }
    
    func setClasses(classes: [Class])
    {
        mutableClasses = classes
    }
    
    /**
        Adds gap if it doesn't overlap with any class
    */
    func addGap(gap: Gap)
    {
        //TODO: Check condition
        mutableGaps.append(gap)
    }
    
    /**
        Adds class if it doesn't overlap with any gap
    */
    func addClass(aClass: Class)
    {
        //TODO: Check condition
        mutableClasses.append(aClass)
    }
}
