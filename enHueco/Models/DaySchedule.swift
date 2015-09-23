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
        Returns true if gap doesn't overlap with any gap or class, excluding eventToExclude.
    */
    func canAddGap(newGap: Gap, excludingEvent eventToExclude:Event? = nil) -> Bool
    {
        let currentDate = NSDate()
        
        let newGapStartHourInCurrentDate = newGap.startHourInUTCEquivalentOfLocalDate(currentDate)
        let newGapEndHourInCurrentDate = newGap.endHourInUTCEquivalentOfLocalDate(currentDate)
        
        for gap in mutableGaps where eventToExclude == nil || gap !== eventToExclude
        {
            let startHourInCurrentDate = gap.startHourInUTCEquivalentOfLocalDate(currentDate)
            let endHourInCurrentDate = gap.endHourInUTCEquivalentOfLocalDate(currentDate)
            
            if newGapStartHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || newGapEndHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || startHourInCurrentDate.isBetween(newGapStartHourInCurrentDate, and: newGapEndHourInCurrentDate)
                || endHourInCurrentDate.isBetween(newGapStartHourInCurrentDate, and: newGapEndHourInCurrentDate)
            {
                return false
            }
        }
        
        for aClass in mutableClasses where eventToExclude == nil || aClass !== eventToExclude
        {
            let startHourInCurrentDate = aClass.startHourInUTCEquivalentOfLocalDate(currentDate)
            let endHourInCurrentDate = aClass.endHourInUTCEquivalentOfLocalDate(currentDate)
            
            if newGapStartHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || newGapEndHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || startHourInCurrentDate.isBetween(newGapStartHourInCurrentDate, and: newGapEndHourInCurrentDate)
                || endHourInCurrentDate.isBetween(newGapStartHourInCurrentDate, and: newGapEndHourInCurrentDate)
            {
                return false
            }
        }
        
        return true
    }

    /**
        Returns true if class doesn't overlap with any gap or class,  excluding eventToExclude.
    */
    func canAddClass(newClass: Class, excludingEvent eventToExclude:Event? = nil) -> Bool
    {
        let currentDate = NSDate()
        
        let newClassStartHourInCurrentDate = newClass.startHourInUTCEquivalentOfLocalDate(currentDate)
        let newClassEndHourInCurrentDate = newClass.endHourInUTCEquivalentOfLocalDate(currentDate)
        
        for gap in mutableGaps where eventToExclude == nil || gap !== eventToExclude
        {
            let startHourInCurrentDate = gap.startHourInUTCEquivalentOfLocalDate(currentDate)
            let endHourInCurrentDate = gap.endHourInUTCEquivalentOfLocalDate(currentDate)
            
            if newClassStartHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || newClassEndHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || startHourInCurrentDate.isBetween(newClassStartHourInCurrentDate, and: newClassEndHourInCurrentDate)
                || endHourInCurrentDate.isBetween(newClassStartHourInCurrentDate, and: newClassEndHourInCurrentDate)
            {
                return false
            }
        }
        
        for aClass in mutableClasses where eventToExclude == nil || aClass !== eventToExclude
        {
            let startHourInCurrentDate = aClass.startHourInUTCEquivalentOfLocalDate(currentDate)
            let endHourInCurrentDate = aClass.endHourInUTCEquivalentOfLocalDate(currentDate)
            
            if newClassStartHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || newClassEndHourInCurrentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate)
                || startHourInCurrentDate.isBetween(newClassStartHourInCurrentDate, and: newClassEndHourInCurrentDate)
                || endHourInCurrentDate.isBetween(newClassStartHourInCurrentDate, and: newClassEndHourInCurrentDate)
            {
                return false
            }
        }
        
        return true
    }
    
    /**
        Adds gap if it doesn't overlap with any gap or class
    */
    func addGap(newGap: Gap) -> Bool
    {
        if canAddGap(newGap)
        {
            mutableGaps.append(newGap)
            return true
        }
        return false
    }
    
    /**
        Adds class if it doesn't overlap with any gap or class
    */
    func addClass(newClass: Class) -> Bool
    {
        if canAddClass(newClass)
        {
            mutableClasses.append(newClass)
            return true
        }
        return false
    }
    
    func removeGap(gap: Gap) -> Bool
    {
        return mutableGaps.removeObject(gap)
    }
    
    func removeClass(aClass: Class) -> Bool
    {
        return mutableClasses.removeObject(aClass)
    }
    
    func gapOrClassWithStartHour(startHour: NSDateComponents) -> Event?
    {
        for gap in gaps
        {
            if gap.startHour == startHour
            {
                return gap
            }
        }
        
        for aClass in classes
        {
            if aClass.startHour == startHour
            {
                return aClass
            }
        }
        
        return nil
    }
    
    //TODO: Implement Equatable protocol
}
