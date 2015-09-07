//
//  Friend.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class User: NSObject
{
    let username: String
    
    let firstNames: String
    let lastNames: String
    
    var name: String { return firstNames + lastNames }
    
    let imageURL: String?
    var phoneNumber: Int!
    
    let schedule = Schedule()
    
    init(username: String, firstNames: String, lastNames: String, phoneNumber:Int!, imageURL: String?)
    {
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        
        super.init()
    }
    
    func currentGap () -> Gap?
    {
        let currentDate = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentDayNumber = calendar.component(.Weekday, fromDate: currentDate)
        
        for gap in schedule.weekDays[currentDayNumber].gaps
        {
            let gapStartHourWithTodaysDate = calendar.dateBySettingHour(gap.startHour.hour, minute: gap.startHour.minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
            let gapEndHourWithTodaysDate = calendar.dateBySettingHour(gap.endHour.hour, minute: gap.endHour.minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
            
            if currentDate.isBetween(gapStartHourWithTodaysDate, and: gapEndHourWithTodaysDate)
            {
                return gap
            }
        }
        
        return nil
    }
    
    func nextGapOrClass () -> Either<Gap, Class>?
    {
        return nil //TODO
    }
}
