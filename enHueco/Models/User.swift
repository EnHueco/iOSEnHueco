//
//  Friend.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding
{
    let username: String
    
    let firstNames: String
    let lastNames: String
    
    var name: String { return firstNames + lastNames }
    
    var imageURL: NSURL?
    var phoneNumber: String!
    
    let schedule = Schedule()
    
    init(username: String, firstNames: String, lastNames: String, phoneNumber:String!, imageURL: NSURL?)
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
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        let currentDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        for gap in schedule.weekDays[currentDayNumber].gaps
        {
            
            let gapStartHourWithTodaysDate = globalCalendar.dateBySettingHour(gap.startHour.hour, minute: gap.startHour.minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
            let gapEndHourWithTodaysDate = globalCalendar.dateBySettingHour(gap.endHour.hour, minute: gap.endHour.minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
            
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
    
    //Mark: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let username = decoder.decodeObjectForKey("username") as? String,
            let firstNames = decoder.decodeObjectForKey("firstNames") as? String,
            let lastNames = decoder.decodeObjectForKey("lastNames") as? String
        else
        {
            self.username = ""
            self.firstNames = ""
            self.lastNames = ""
            self.phoneNumber = ""

            super.init()
            return nil
        }
        
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = decoder.decodeObjectForKey("phoneNumber") as? String
        self.imageURL = decoder.decodeObjectForKey("imageURL") as? NSURL
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(username, forKey: "username")
        coder.encodeObject(firstNames, forKey: "firstNames")
        coder.encodeObject(lastNames, forKey: "lastNames")
        coder.encodeObject(phoneNumber, forKey: "phoneNumber")
        coder.encodeObject(imageURL, forKey: "imageURL")
    }
}
