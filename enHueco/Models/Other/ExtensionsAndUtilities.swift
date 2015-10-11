//
//  ExtensionsAndUtilities.swift
//  enHueco
//
//  Created by Diego on 9/6/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

enum Either<T1, T2>
{
    case Left(T1)
    case Right(T2)
}

func >(lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs.compare(rhs) == .OrderedDescending
}

func <(lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate
{    
    func isBetween(startDate:NSDate, and endDate:NSDate) -> Bool
    {
        return startDate.compare(self) == .OrderedAscending && endDate.compare(self) == .OrderedDescending
    }
    
    func hasSameHoursAndMinutesThan(date:NSDate) -> Bool
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let hourMinute: NSCalendarUnit = [.Hour, .Minute]

        let lhsComp = calendar!.components(hourMinute, fromDate: self)
        let rhsComp = calendar!.components(hourMinute, fromDate: date)
        
        return lhsComp.hour == rhsComp.hour && lhsComp.minute == rhsComp.minute
    }
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    convenience init?(serverFormattedString: String)
    {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd/MM/yyyy"
        let possibleDate = dateStringFormatter.dateFromString(serverFormattedString)
        
        guard let date = possibleDate else { return nil }
        
        self.init(timeInterval:0, sinceDate:date)
    }
}

extension NSDateComponents
{
    /**
        Returns a new instance of NSDateComponents with all its components set to 0 except for the ones provided.
    */
    convenience init(weekday: Int, hour: Int, minute: Int)
    {
        self.init()

        self.weekday = weekday
        self.hour = hour
        self.minute = minute
    }
}

func -(lhs: NSDate, rhs: NSDate) -> NSDateComponents
{
    let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
    
    return NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: rhs, toDate: lhs, options: [])
}

extension Array
{
    mutating func removeObject<U: Equatable>(object: U) -> Bool
    {
        var index: Int?
        
        for (idx, objectToCompare) in self.enumerate()
        {
            if let to = objectToCompare as? U
            {
                if object == to
                {
                    index = idx
                }
            }
        }
        
        if(index != nil)
        {
            self.removeAtIndex(index!)
            return true
        }
        
        return false
    }
}