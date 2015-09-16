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
        for aClass in mutableClasses
        {
            if      aClass.startHour.hour <= gap.startHour.hour
                &&  aClass.startHour.minute <= gap.startHour.minute
                &&  gap.startHour.hour <= aClass.endHour.hour
                &&  gap.startHour.minute < aClass.endHour.minute
            {
                // Class starts in between a gap
                return
            }
            else if aClass.startHour.hour <= gap.endHour.hour
                &&  aClass.startHour.minute < gap.endHour.minute
                &&  gap.endHour.hour <= aClass.endHour.hour
                &&  gap.endHour.minute <= aClass.endHour.minute
            {
                // Class ends in between a gap
                return
            }
            
        }
        mutableGaps.append(gap)
    }
    
    /**
        Adds class if it doesn't overlap with any gap
    */
    func addClass(aClass: Class)
    {
        for gap in mutableGaps
        {
            if gap.startHour.hour <= aClass.startHour.hour
            && gap.startHour.minute <= aClass.startHour.minute
            &&  aClass.startHour.hour <= gap.endHour.hour
            &&  aClass.startHour.minute < gap.endHour.minute
            {
                // Class starts in between a gap
                return
            }
            else if gap.startHour.hour <= aClass.endHour.hour
            &&  gap.startHour.minute < aClass.endHour.minute
            &&  aClass.endHour.hour <= gap.endHour.hour
            &&  aClass.endHour.minute <= gap.endHour.minute
            {
                // Class ends in between a gap
                return
            }
            
        }
        mutableClasses.append(aClass)
    }
    
    func removeGap(gap: Gap)
    {
        mutableGaps.removeObject(gap)
    }
    
    func removeClass(aClass: Class)
    {
        mutableClasses.removeObject(aClass)
    }
    
    //TODO: Implement Equatable protocol
}
