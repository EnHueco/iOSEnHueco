//
//  AppUser.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import EventKit

class AppUser: User
{
    /**
        Session token
    */
    var token : String
    
    var friends = [User]()
    var friendRequests = [String]()
    
    init(username: String, token : String, lastUpdatedOn: NSDate!, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?)
    {
        self.token = token
        
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL)
    }
    
    /**
        Returns all friends that are currently in gap.
        - returns: Friend in gap with their current gap
    */
    func friendsCurrentlyInGap() -> [(friend: User, gap: Gap)]
    {
        var friendsAndGaps = [(friend: User, gap: Gap)]()
        
        for friend in friends
        {
            if let gap = friend.currentGap()  { friendsAndGaps.append((friend, gap))}
        }
        
        return friendsAndGaps
    }
    
    func updateFriendsAndFriendsSchedules ()
    {
        let params = []
        let URL = NSURL(string: APIURLS.URLS.base.rawValue)!
        
        HTTPRequestResponseManager.sendAsyncRequestToURL(URL, usingMethod: .POST, withJSONParams: nil, onSuccess: { (response) -> () in
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates.rawValue, object: self, userInfo: nil)
            
        }) { (error) -> () in
                
                
        }
    }
    
    func sendFriendRequest ()
    {
        
    }
    
    func sendFriendRequestToUserWithUsername (username: String)
    {
        
    }
    
    /**
        Adds friend from their string encoded representation.
        The AppUser user is also added as a friend of the friend they are adding, without any approvals from either side.
    */
    func addFriendFromStringEncodedFriendRepresentation (encodedFriend: String) throws
    {
        let mainComponents = encodedFriend.componentsSeparatedByString("/")
        
        let username = mainComponents[0]
        
        let fullNameComponents = mainComponents[1].componentsSeparatedByString("&")
        let firstNames = fullNameComponents[0]
        let lastNames = fullNameComponents[1]
        
        let phoneNumber = mainComponents[2]
        
        let friend = User(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: nil)

        let encodedWeekDays = mainComponents[4].componentsSeparatedByString("|")
        
        for (i, encodedWeekDay) in encodedWeekDays.enumerate()
        {
            var gaps = [Gap]()
            var classes = [Class]()

            let encodedWeekDayComponents = encodedWeekDay.componentsSeparatedByString("#")
            let encodedGaps = encodedWeekDayComponents[0].componentsSeparatedByString("&")
            
            if encodedWeekDayComponents[0] != ""
            {
                for encodedGap in encodedGaps
                {
                    let hoursComponents = encodedGap.componentsSeparatedByString("-")
                    
                    let startHourComponents = hoursComponents[0].componentsSeparatedByString(":")
                    let startHourDateComponents = NSDateComponents()
                    startHourDateComponents.hour = Int(startHourComponents[0])!
                    startHourDateComponents.minute = Int(startHourComponents[1])!
                    
                    let endHourComponents = hoursComponents[1].componentsSeparatedByString(":")
                    let endHourDateComponents = NSDateComponents()
                    endHourDateComponents.hour = Int(endHourComponents[0])!
                    endHourDateComponents.minute = Int(endHourComponents[1])!
                    
                    gaps.append(Gap(daySchedule: schedule.weekDays[i], startHour: startHourDateComponents, endHour: endHourDateComponents))
                }
            }
            
            if encodedWeekDayComponents[1] != ""
            {
                let encodedClasses = encodedWeekDayComponents[1].componentsSeparatedByString("&")
                
                for encodedClass in encodedClasses
                {
                    let classComponents = encodedClass.componentsSeparatedByString("-")
                    
                    let name: String? = classComponents[0] != "" ? classComponents[0] : nil
                    
                    let startHourComponents = classComponents[1].componentsSeparatedByString(":")
                    let startHourDateComponents = NSDateComponents()
                    startHourDateComponents.hour = Int(startHourComponents[0])!
                    startHourDateComponents.minute = Int(startHourComponents[1])!
                    
                    let endHourComponents = classComponents[2].componentsSeparatedByString(":")
                    let endHourDateComponents = NSDateComponents()
                    endHourDateComponents.hour = Int(endHourComponents[0])!
                    endHourDateComponents.minute = Int(endHourComponents[1])!
                    
                    let location = classComponents[3]
                    
                    classes.append(Class(daySchedule: schedule.weekDays[i], name:name, startHour: startHourDateComponents, endHour: endHourDateComponents, location: (location != "" ? location:nil) ))
                }
            }
            
            friend.schedule.weekDays[i].setGaps(gaps)
            friend.schedule.weekDays[i].setClasses(classes)
        }
        

        for (index, aFriend) in friends.enumerate()
        {
            if aFriend.username == friend.username
            {
                friends[index] = friend
                break
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidAddFriend.rawValue, object: system, userInfo: nil)
    }
    
    /**
        Adds the AppUser as a friend of the friend they just added by string encoded representation (QR)
        App user is added as a friend on the server directly (without friends confirmation)
        Must only be called from "addFriendFromStringEncodedFriendRepresentation:".
    */
    private func _addAppUserAsFriendOfStringEncodedAddedFriend ()
    {
        // TODO
    }
    
    /**
        Resturns the string encoded representation of the user, to be decoded by "addFriendFromStringEncodedFriendRepresentation:"
        Formatted as follows:
        username/first names, last names/phone number/imageURL/00:00-00:10,00:30-01:30/00:00-00:10,00:30-01:30
    */
    func stringEncodedUserRepresentation () -> String
    {
        var encodedSchedule = username
        encodedSchedule += "/" + firstNames + "&" + lastNames
        encodedSchedule += "/" + String(phoneNumber)
        encodedSchedule += "/ /"
        
        for (i, daySchedule) in schedule.weekDays.enumerate()
        {
            for (j, gap) in daySchedule.gaps.enumerate()
            {
                encodedSchedule += "\(gap.startHour.hour):\(gap.startHour.minute)"
                encodedSchedule += "-"
                encodedSchedule += "\(gap.endHour.hour):\(gap.endHour.minute)"

                if j != daySchedule.gaps.count-1 { encodedSchedule += "&" }
            }
            
            encodedSchedule += "#"
            
            for (j, aClass) in daySchedule.classes.enumerate()
            {
                if let name = aClass.name { encodedSchedule += name }
                encodedSchedule += "-"
                encodedSchedule += "\(aClass.startHour.hour):\(aClass.startHour.minute)"
                encodedSchedule += "-"
                encodedSchedule += "\(aClass.endHour.hour):\(aClass.endHour.minute)"
                if let location = aClass.location { encodedSchedule += "-" + location }
                
                if j != daySchedule.classes.count-1 { encodedSchedule += "&" }
            }
            
            if i != schedule.weekDays.count-1 { encodedSchedule += "|" }
        }
        
        return encodedSchedule
    }
    
    /** 
        Imports an schedule of classes from a device's calendar.
        - parameter generateGapsBetweenClasses: If gaps between classes should be calculated and added to the schedule.
    */
    func importScheduleFromCalendar(calendar: EKCalendar, generateGapsBetweenClasses:Bool) -> Bool
    {
        let today = NSDate()
        let eventStore = EKEventStore()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        localCalendar.locale = NSLocale.currentLocale()
        
        let componentUnits: NSCalendarUnit = [.Year, .WeekOfYear, .Weekday, .Hour, .Minute, .Second]
        var components = NSCalendar.currentCalendar().components(componentUnits, fromDate:today)
        
        components.weekday = 6
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let nextFridayAtEndOfDay = localCalendar.dateFromComponents(components)!
        
        components = NSCalendar.currentCalendar().components(componentUnits, fromDate:today)
        
        components.weekday = 2
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let lastMondayAtStartOfDay = localCalendar.dateFromComponents(components)!

        let calendars = [calendar]
        
        let fetchEventsPredicate = eventStore.predicateForEventsWithStartDate(lastMondayAtStartOfDay, endDate: nextFridayAtEndOfDay, calendars: calendars)
        let fetchedEvents = eventStore.eventsMatchingPredicate(fetchEventsPredicate)
        
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        for event in fetchedEvents
        {
            let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]
            let startDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: event.startDate)
            let endDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: event.endDate)

            let weekDayDaySchedule = schedule.weekDays[startDateComponents.weekday]
            let aClass = Class(daySchedule: weekDayDaySchedule, name:event.title, startHour: startDateComponents, endHour: endDateComponents, location: event.location)
            
            weekDayDaySchedule.addClass(aClass)
        }
        
        if generateGapsBetweenClasses
        {
            //TODO: Calculate Gaps and add them
        }
        
        return true
    }
    
    //NSCoding 
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let token = decoder.decodeObjectForKey("token") as? String,
            //let lastUpdatedOn = decoder.decodeObjectForKey("lastUpdatedOn") as? NSDate,
            let friends = decoder.decodeObjectForKey("friends") as? [User],
            let friendRequests = decoder.decodeObjectForKey("friendRequests") as? [String]
        else
        {
            self.token = ""
            self.friends = [User]()
            self.friendRequests = [String]()
            super.init(coder: decoder)
            
            return nil
        }
        
        self.token = token
        //self.lastUpdatedOn = lastUpdatedOn
        self.friends = friends
        self.friendRequests = friendRequests
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(token, forKey: "token")
        //coder.encodeObject(lastUpdatedOn, forKey: "lastUpdatedOn")
        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(friendRequests, forKey: "friendRequests")
    }
}

