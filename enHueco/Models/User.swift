//
//  Friend.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class User: EHSynchronizable
{
    let username: String
    
    var firstNames: String
    var lastNames: String
    
    var name: String { return "\(firstNames) \(lastNames)" }
    
    var imageURL: NSURL?
    var phoneNumber: String! = ""
    
    var schedule: Schedule
    
    /// (For efficiency) True if the user is near the App User at the current time, given the currentBSSID values.
    private(set) var isNearby = false
    
    var currentBSSID: String?
    {
        didSet
        {
            if oldValue != currentBSSID
            {
                refreshIsNearby()
            }
        }
    }
    
    init(username: String, firstNames: String, lastNames: String, phoneNumber:String!, imageURL: NSURL?, ID: String, lastUpdatedOn: NSDate)
    {
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        
        schedule = Schedule()
        
        super.init(ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    convenience init(JSONDictionary: [String : AnyObject])
    {
        let username = JSONDictionary["login"] as! String
        let firstNames = JSONDictionary["firstNames"] as! String
        let lastNames = JSONDictionary["lastNames"] as! String
        let imageURL:NSURL? = ((JSONDictionary["imageURL"] == nil || JSONDictionary["imageURL"] is NSNull) ? nil : NSURL(string: (EHURLS.Base+(JSONDictionary["imageURL"]! as! String)).replace("https", withString: "http")))
        let phoneNumber = JSONDictionary["phoneNumber"] as? String
        let lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
        
        self.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber ?? "", imageURL: imageURL, ID:username, lastUpdatedOn: lastUpdatedOn)
    }
    
    func updateUserWithJSONDictionary(JSONDictionary: [String : AnyObject])
    {
        self.firstNames = JSONDictionary["firstNames"] as! String
        self.lastNames = JSONDictionary["lastNames"] as! String
        self.imageURL = ((JSONDictionary["imageURL"] == nil || JSONDictionary["imageURL"] is NSNull) ? nil : NSURL(string: (EHURLS.Base+(JSONDictionary["imageURL"]! as! String)).replace("https", withString: "http")))
        self.phoneNumber = JSONDictionary["phoneNumber"] as? String
        self.lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
    }
    
    func addEvents(JSONDictionary: [String: AnyObject])
    {
        let eventSet = JSONDictionary["gap_set"] as! [[String : AnyObject]]
       
        for eventJSON in eventSet
        {
            let event = Event(JSONDictionary: eventJSON)
            schedule.weekDays[event.localWeekDay()].addEvent(event)
        }
    }
    
    /// Returns user current gap, or nil if user is not in a gap.
    func currentGap () -> Event?
    {
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!        
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        for event in schedule.weekDays[localWeekDayNumber].events where event.type == .Gap
        {
            let startHourInCurrentDate = event.startHourInDate(currentDate)
            let endHourInCurrentDate = event.endHourInDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate)
            {
                return event
            }
        }

        return nil
    }
    
    ///For Performance
    func currentAndNextGap () -> (currentGap: Event?, nextGap: Event?)
    {
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        let localWeekdayEvents = schedule.weekDays[localWeekDayNumber].events
        
        var currentGap: Event?
        
        for event in localWeekdayEvents where event.type == .Gap
        {
            let startHourInCurrentDate = event.startHourInDate(currentDate)
            let endHourInCurrentDate = event.endHourInDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate)
            {
                currentGap = event
            }
            else if startHourInCurrentDate > currentDate
            {
                return (currentGap, event)
            }
        }
        
        return (currentGap, nil)
    }
    
    /// Returns user's next gap or class
    func nextEvent () -> Event?
    {
        return nil //TODO: 
    }
    
    func nextGap () -> Event?
    {
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)

        for event in schedule.weekDays[localWeekDayNumber].events where event.type == .Gap && event.startHourInDate(currentDate) > currentDate
        {
            return event
        }
        
        return nil
    }
    
    /// When current BSSID is set, checks if user is near the App User and updates the value of the isNearby property.
    func refreshIsNearby()
    {
        if let appUserBSSID = system.appUser.currentBSSID, currentBSSID = currentBSSID
        {
            isNearby = ProximityManager.sharedManager().wifiAccessPointWithBSSID(appUserBSSID, isNearAccessPointWithBSSID: currentBSSID)
        }
        else
        {
            isNearby = false
        }
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let username = decoder.decodeObjectForKey("username") as? String,
            let firstNames = decoder.decodeObjectForKey("firstNames") as? String,
            let lastNames = decoder.decodeObjectForKey("lastNames") as? String,
            let schedule = decoder.decodeObjectForKey("schedule") as? Schedule
        else
        {
            self.username = ""
            self.firstNames = ""
            self.lastNames = ""
            self.phoneNumber = ""
            self.schedule = Schedule()

            super.init(coder: decoder)
            return nil
        }
        
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = decoder.decodeObjectForKey("phoneNumber") as? String
        self.imageURL = decoder.decodeObjectForKey("imageURL") as? NSURL
        self.schedule = schedule
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(username, forKey: "username")
        coder.encodeObject(firstNames, forKey: "firstNames")
        coder.encodeObject(lastNames, forKey: "lastNames")
        coder.encodeObject(phoneNumber, forKey: "phoneNumber")
        coder.encodeObject(imageURL, forKey: "imageURL")
        coder.encodeObject(schedule, forKey: "schedule")
        
        super.encodeWithCoder(coder)
    }
    
}
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

