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

extension NSDate
{    
    func isBetween(startDate:NSDate, and endDate:NSDate) -> Bool
    {
        return startDate.compare(self) == .OrderedAscending && endDate.compare(self) == .OrderedDescending
    }
    

}

func -(lhs: NSDate, rhs: NSDate) -> NSDateComponents
{
    let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
    
    return NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: rhs, toDate: lhs, options: [])
}