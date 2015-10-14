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
    /// Session token
    var token : String
    
    var friends = [User]()
    var outgoingFriendRequests = [User]()
    var incomingFriendRequests = [User]()
    
    init(username: String, token : String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?, ID: String, lastUpdatedOn: NSDate)
    {
        self.token = token
        
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    // MARK: Updates
    
    /**
    Checks for updates on the server including Session Status, Friend list, Friends Schedule, User's Info
    */
    func fetchUpdates ()
    {
        fetchUpdatesForFriendRequests()
        fetchUpdatesForFriendsAndFriendSchedules()
    }
    
    /**
    Fectches updates for outgoing both outgoing and incoming friend requests on the server and notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidReceiveFriendRequestUpdates in case of success
    */
    func fetchUpdatesForFriendRequests()
    {
        let params = [EHParameters.UserID.rawValue: username, EHParameters.Token.rawValue: token]
        let outgoingRequestsURL = NSURL(string: EHURLS.Base.rawValue + EHURLS.OutgoingFriendRequestsSegment.rawValue)!
        
        ConnectionManager.sendAsyncRequestToURL(outgoingRequestsURL, usingMethod: .GET, withJSONParams: params, onSuccess: { (outgoingRequestsResponseDictionary) -> () in
            
            let incomingRequestsURL = NSURL(string: EHURLS.Base.rawValue + EHURLS.IncomingFriendRequestsSegment.rawValue)!
            
            guard let incomingRequestsResponseDictionary = try? ConnectionManager.sendSyncRequestToURL(incomingRequestsURL, usingMethod: .GET, withJSONParams: params)
            else { return }
            
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendRequestUpdates.rawValue, object: self, userInfo: nil)
            
        }) { (error) -> () in
                
            
        }
    }
    
    /**
    Fetches full friends and schedule information from the server and notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates in case of success
    */
    func fetchUpdatesForFriendsAndFriendSchedules()
    {
        let params = [EHParameters.UserID.rawValue: username, EHParameters.Token.rawValue: token]
        let URL = NSURL(string: EHURLS.Base.rawValue + EHURLS.FriendSegment.rawValue)!
        
        var newFriends = [User]()
        
        ConnectionManager.sendAsyncRequestToURL(URL, usingMethod: .GET, withJSONParams: params, onSuccess: { (response) -> () in
            
            let currentDate = NSDate()
            
            let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            
            let globalCalendar = NSCalendar.currentCalendar()
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!
            
            for friendJSON in response as! [[String: AnyObject]]
            {
                let newFriend = User(JSONDictionary: friendJSON)
                
                let scheduleJSON = friendJSON["schedule"] as! [String: AnyObject]
                let eventsJSON = scheduleJSON["events"] as! [[String: AnyObject]]
                
                for eventJSON in eventsJSON
                {
                    let newEvent = Event(JSONDictionary: eventJSON)
                    
                    let startHourWeekDayConversionComponents = NSDateComponents()
                    startHourWeekDayConversionComponents.year = globalCalendar.component(.Year, fromDate: currentDate)
                    startHourWeekDayConversionComponents.month = globalCalendar.component(.Month, fromDate: currentDate)
                    startHourWeekDayConversionComponents.weekOfMonth = globalCalendar.component(.WeekOfMonth, fromDate: currentDate)
                    startHourWeekDayConversionComponents.weekday = newEvent.startHour.weekday
                    startHourWeekDayConversionComponents.hour = newEvent.startHour.hour
                    startHourWeekDayConversionComponents.minute = newEvent.startHour.minute
                    startHourWeekDayConversionComponents.second = 0
                    
                    let startHourInDate = globalCalendar.dateFromComponents(startHourWeekDayConversionComponents)!
                    let localStartHourWeekDay = localCalendar.component(NSCalendarUnit.Weekday, fromDate: startHourInDate)
                    
                    let daySchedule = newFriend.schedule.weekDays[localStartHourWeekDay]
                    daySchedule.addEvent(newEvent)
                }
                
                newFriends.append(newFriend)
            }
            
            self.friends = newFriends
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates.rawValue, object: self, userInfo: nil)
            
        }) { (error) -> () in
                
            
        }
    }
    
    // MARK: Functions
    
    /**
    Returns a schedule with the common gaps of the users provided.
    */
    func commonGapsScheduleForUsers(users:[User]) -> Schedule
    {
        let currentDate = NSDate()
        let commonGapsSchedule = Schedule()
        
        guard users.count >= 2 else { return commonGapsSchedule }
        
        for i in 1..<schedule.weekDays.count
        {
            var currentCommonGaps = users.first!.schedule.weekDays[i].events.filter { $0.type == .Gap }
            
            for j in 1..<users.count
            {
                var newCommonGaps = [Event]()
                
                for gap1 in currentCommonGaps
                {
                    let startHourInCurrentDate1 = gap1.startHourInDate(currentDate)
                    let endHourInCurrentDate1 = gap1.endHourInDate(currentDate)
                    
                    for gap2 in users[j].schedule.weekDays[i].events.filter({ $0.type == .Gap })
                    {
                        let startHourInCurrentDate2 = gap2.startHourInDate(currentDate)
                        let endHourInCurrentDate2 = gap2.endHourInDate(currentDate)
                        
                        if !(endHourInCurrentDate1 < startHourInCurrentDate2 || startHourInCurrentDate1 > endHourInCurrentDate2)
                        {
                            let newStartHour = (startHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? gap1.startHour : gap2.startHour)
                            let newEndHour = (endHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? gap1.endHour : gap2.endHour)
                            
                            newCommonGaps.append(Event(type: .Gap, startHour: newStartHour, endHour: newEndHour))
                        }
                    }
                }
                
                currentCommonGaps = newCommonGaps
            }
            
            commonGapsSchedule.weekDays[i].setEvents(currentCommonGaps)
        }
        
        return commonGapsSchedule
    }
    
    /**
    Returns all friends that are currently in gap.
    - returns: Friend in gap with their current gap
    */
    func friendsCurrentlyInGap() -> [(friend: User, gap: Event)]
    {
        var friendsAndGaps = [(friend: User, gap: Event)]()
        
        for friend in friends
        {
            if let gap = friend.currentGap()  {friendsAndGaps.append((friend, gap))}
        }
        
        return friendsAndGaps
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
        
        let componentUnits: NSCalendarUnit = [.Year, .WeekOfYear, .Weekday, .Hour, .Minute, .Second]
        var components = localCalendar.components(componentUnits, fromDate:today)
        
        components.weekday = 6
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let nextFridayAtEndOfDay = localCalendar.dateFromComponents(components)!
        
        components = localCalendar.components(componentUnits, fromDate:today)
        
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
            let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: event.startDate)
            
            let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]
            
            let startDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: event.startDate)
            let endDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: event.endDate)
            
            let weekDayDaySchedule = schedule.weekDays[localWeekDayNumber]
            let aClass = Event(type:.Class, name:event.title, startHour: startDateComponents, endHour: endDateComponents, location: event.location)
            
            weekDayDaySchedule.addEvent(aClass)
        }
        
        if generateGapsBetweenClasses
        {
            //TODO: Calculate Gaps and add them
        }
        return true
    }
    
    // MARK: Friend Requests
    
    /**
    Sends a friend request to the username provided and notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidSendFriendRequest in case of success
    - EHSystemNotification.SystemDidFailToSendFriendRequest in case of failure
    */
    func sendFriendRequestToUserWithUsername (username: String)
    {
        let URL = NSURL(string: EHURLS.Base.rawValue + EHURLS.FriendSegment.rawValue + "/" + username + "/")!
        
        ConnectionManager.sendAsyncRequestToURL(URL, usingMethod: HTTPMethod.POST, withJSONParams: nil, onSuccess: { (JSONResponse) -> () in
            
            let requestFriend = User(JSONDictionary: JSONResponse)
            self.outgoingFriendRequests.append(requestFriend)
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidSendFriendRequest.rawValue, object: self, userInfo: nil)
            
        }) { (error) -> () in
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidFailToSendFriendRequest.rawValue, object: self, userInfo: nil)
        }
    }
    
    /*
    /**
    Adds friend from their string encoded representation and notifies via Notification Center.
    The AppUser user is also added as a friend of the friend they are adding, without any approvals from either side.
    
    ### Notifications
    - EHSystemNotification.SystemDidAddFriend in case of success
    */
    func addFriendFromStringEncodedFriendRepresentation (encodedFriend: String) throws
    {
        let mainComponents = encodedFriend.componentsSeparatedByString("/")
        
        let username = mainComponents[0]
        
        let fullNameComponents = mainComponents[1].componentsSeparatedByString("&")
        let firstNames = fullNameComponents[0]
        let lastNames = fullNameComponents[1]
        
        let phoneNumber = mainComponents[2]
        
        let friend = User(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: nil, ID: username, lastUpdatedOn: NSDate())

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
                    
                    gaps.append(Gap(startHour: startHourDateComponents, endHour: endHourDateComponents))
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
                    
                    classes.append(Class(name:name, startHour: startHourDateComponents, endHour: endHourDateComponents, location: (location != "" ? location:nil) ))
                }
            }
            
            friend.schedule.weekDays[i].setGaps(gaps)
            friend.schedule.weekDays[i].setClasses(classes)
        }
        
        var existingFriend = false
        for (index, aFriend) in friends.enumerate()
        {
            if aFriend.username == friend.username
            {
                existingFriend = true
                friends[index] = friend
                break
            }
        }
        if !existingFriend { friends.append(friend)}
        
        NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidAddFriend.rawValue, object: system, userInfo: nil)
    }*/
    
    /**
    Adds the AppUser as a friend of the friend they just added by string encoded representation (QR)
    App user is added as a friend on the server directly (without friends confirmation)
    **Must only be called from "addFriendFromStringEncodedFriendRepresentation:"**.
    */
    private func _addAppUserAsFriendOfStringEncodedAddedFriend ()
    {
        // TODO: Complete
    }
    
    /*
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
    }*/
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let token = decoder.decodeObjectForKey("token") as? String,
            let friends = decoder.decodeObjectForKey("friends") as? [User],
            let incomingFriendRequests = decoder.decodeObjectForKey("incomingFriendRequests") as? [User],
            let outgoingFriendRequests = decoder.decodeObjectForKey("outgoingFriendRequests") as? [User]
        else
        {
            self.token = ""
            self.friends = [User]()
            self.incomingFriendRequests = [User]()
            self.outgoingFriendRequests = [User]()
            super.init(coder: decoder)
            
            return nil
        }
        
        self.token = token
        self.friends = friends
        self.incomingFriendRequests = incomingFriendRequests
        self.outgoingFriendRequests = outgoingFriendRequests
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(token, forKey: "token")
        //coder.encodeObject(lastUpdatedOn, forKey: "lastUpdatedOn")
        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(incomingFriendRequests, forKey: "incomingFriendRequests")
        coder.encodeObject(outgoingFriendRequests, forKey: "outgoingFriendRequests")
    }
}

