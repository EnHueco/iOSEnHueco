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
    
    ///Dictionary containing the AppUser's friends with their usernames as their keys
    var friends = [String : User]()
    
    var outgoingFriendRequests = [User]()
    var incomingFriendRequests = [User]()
    
    ///User visibility state
    var invisible = false
    
    // Encoding characters
    
    let splitCharacter = "\\"
    let separationCharacter = "-"
    let multipleElementsCharacter = ","
    let hourMinuteSeparationCharacter = ":"
    
    init(username: String, token : String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?, ID: String, lastUpdatedOn: NSDate)
    {
        self.token = token
        
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    convenience init(JSONDictionary: [String : AnyObject])
    {
        let token = JSONDictionary["value"] as? String
        let user = User(JSONDictionary: JSONDictionary["user"] as! [String : AnyObject])
        
        self.init(username: user.username, token: token ?? system.appUser.token, firstNames: user.firstNames, lastNames: user.lastNames, phoneNumber: nil, imageURL: user.imageURL, ID: user.ID!, lastUpdatedOn: user.lastUpdatedOn)
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let token = decoder.decodeObjectForKey("token") as? String,
            let friends = decoder.decodeObjectForKey("friends") as? [String : User],
            let incomingFriendRequests = decoder.decodeObjectForKey("incomingFriendRequests") as? [User],
            let outgoingFriendRequests = decoder.decodeObjectForKey("outgoingFriendRequests") as? [User]
            else
        {
            self.token = ""
            self.friends = [String : User]()
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
        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(incomingFriendRequests, forKey: "incomingFriendRequests")
        coder.encodeObject(outgoingFriendRequests, forKey: "outgoingFriendRequests")
    }
    
    // MARK: Updates
    
    //TODO: What is this method for?
    func fetchAppUser ()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            let downloadedUser = JSONResponse as! [String : AnyObject]
            
            if self.isOutdatedBasedOnDate(NSDate(serverFormattedString: downloadedUser["updated_on"] as! String)!)
            {
                self.updateUserWithJSONDictionary(downloadedUser)
                self.downloadProfilePicture()
            }
            
        }) { (error) -> () in
                
            print(error)
        }
    }
    
    /**
    Checks for updates on the server including Session Status, Friend list, Friends Schedule, User's Info
    */
    func fetchUpdates ()
    {
        fetchUpdatesForFriendRequests()
        fetchUpdatesForFriendsAndFriendSchedules()
    }
    
    func fetchUpdatesForAppUserAndSchedule ()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            let JSONDictionary = JSONResponse as! [String : AnyObject]
            self.updateUserWithJSONDictionary(JSONDictionary)
            
            self.schedule = Schedule()
            let eventSet = JSONDictionary["gap_set"] as! [[String : AnyObject]]
            
            for eventJSON in eventSet
            {
                let event = Event(JSONDictionary: eventJSON)
                self.schedule.weekDays[event.localWeekDay()].addEvent(event)
            }
            
        }) { (error) -> () in
            print(error)
        }
    }
    
    /**
    Fetches updates for both outgoing and incoming friend requests on the server and notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidReceiveFriendRequestUpdates in case of success
    */
    func fetchUpdatesForFriendRequests()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.IncomingFriendRequestsSegment)!)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (incomingRequestsResponseDictionary) -> () in
            
            var requestFriends = [User]()
            
            for friendJSON in incomingRequestsResponseDictionary as! [[String : AnyObject]]
            {
                requestFriends.append(User(JSONDictionary: friendJSON))
            }
            
            self.incomingFriendRequests = requestFriends
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendRequestUpdates, object: system, userInfo: nil)
            }
            
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
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment)!)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "GET"
        
        var newFriends = [String : User]()
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (response) -> () in
            
            let currentDate = NSDate()
            
            let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            
            let globalCalendar = NSCalendar.currentCalendar()
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!
            
            for friendJSON in response as! [[String: AnyObject]]
            {
                let newFriend = User(JSONDictionary: friendJSON)
                
                let eventsJSON = friendJSON["gap_set"] as! [[String: AnyObject]]
                
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
                
                self.friends[newFriend.username] = newFriend
            }
            
//            self.friends = newFriends
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: self, userInfo: nil)
            }
            
        }) { (error) -> () in
                
         print(error)
        }
    }
    
    func fetchUpdatesForFriendLocations (successHandler: () -> (), failureHandler: () -> ())
    {
        
    }
    
    // MARK: Functions
    
    /**
    Returns a schedule with the common free time periods of the users provided.
    */
    func commonFreeTimePeriodsScheduleForUsers(users:[User]) -> Schedule
    {
        let currentDate = NSDate()
        let commonFreeTimePeriodsSchedule = Schedule()
        
        guard users.count >= 2 else { return commonFreeTimePeriodsSchedule
        }
        
        for i in 1..<schedule.weekDays.count
        {
            var currentCommonFreeTimePeriods = users.first!.schedule.weekDays[i].events.filter { $0.type == .FreeTime }
            
            for j in 1..<users.count
            {
                var newCommonFreeTimePeriods = [Event]()
                
                for freeTimePeriod1 in currentCommonFreeTimePeriods
                {
                    let startHourInCurrentDate1 = freeTimePeriod1.startHourInDate(currentDate)
                    let endHourInCurrentDate1 = freeTimePeriod1.endHourInDate(currentDate)
                    
                    for freeTimePeriod2 in users[j].schedule.weekDays[i].events.filter({ $0.type == .FreeTime })
                    {
                        let startHourInCurrentDate2 = freeTimePeriod2.startHourInDate(currentDate)
                        let endHourInCurrentDate2 = freeTimePeriod2.endHourInDate(currentDate)
                        
                        if !(endHourInCurrentDate1 < startHourInCurrentDate2 || startHourInCurrentDate1 > endHourInCurrentDate2)
                        {
                            let newStartHour = (startHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? freeTimePeriod1.startHour : freeTimePeriod2.startHour)
                            let newEndHour = (endHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? freeTimePeriod1.endHour : freeTimePeriod2.endHour)
                            
                            newCommonFreeTimePeriods.append(Event(type: .FreeTime, startHour: newStartHour, endHour: newEndHour))
                        }
                    }
                }
                
                currentCommonFreeTimePeriods = newCommonFreeTimePeriods
            }
            
            commonFreeTimePeriodsSchedule.weekDays[i].setEvents(currentCommonFreeTimePeriods)
        }
        
        return commonFreeTimePeriodsSchedule
    }
    
    /**
     Returns all friends that are currently available and nearby.
     - returns: Friend with their current free time period
     */
    func currentlyAvailableAndNearbyFriends() -> [(friend: User, freeTime: Event)]
    {
        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
        
        for friend in friends.values
        {
            if let freeTime = friend.currentFreeTimePeriod() where friend.isNearby
            {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }
        
        return friendsAndFreeTimePeriods
    }
    
    func friendsCurrentlyNearby() -> [User]
    {
        return friends.values.filter { $0.isNearby }
    }
    
    /**
    Returns all friends that are currently available.
    - returns: Friends with their current free time periods
    */
    func currentlyAvailableFriends() -> [(friend: User, freeTime: Event)]
    {        
        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
        
        for friend in friends.values
        {
            if let freeTime = friend.currentFreeTimePeriod()
            {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }
        
        return friendsAndFreeTimePeriods
    }
        
    /**
     Returns all friends that will soon be available.
     - returns: Friends with their current free time period
     */
    func soonAvailableFriendsWithinTimeInterval(interval: NSTimeInterval) -> [(friend: User, freeTime: Event)]
    {
        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
        
        let currentDate = NSDate()
        
        for friend in friends.values
        {
            if let freeTime = friend.nextFreeTimePeriod() where freeTime.startHourInDate(currentDate).timeIntervalSinceNow <= interval
            {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }
        
        return friendsAndFreeTimePeriods
    }
    
    /**
    Imports an schedule of classes from a device's calendar.
    - parameter generateFreeTimePeriodsBetweenClasses: If gaps between classes should be calculated and added to the schedule.
    */
    func importScheduleFromCalendar(calendar: EKCalendar, generateFreeTimePeriodsBetweenClasses:Bool) -> Bool
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
            
            if weekDayDaySchedule.addEvent(aClass)
            {
                SynchronizationManager.sharedManager().reportNewEvent(aClass)
            }
        }
        
        if generateFreeTimePeriodsBetweenClasses
        {
            //TODO: Calculate Gaps and add them
        }
        return true
    }
    
    /// When currentBSSID is set, refreshes the isNearby property for all friends.
    override func refreshIsNearby()
    {
        for friend in friends.values
        {
            friend.refreshIsNearby()
        }
    }
    
    // MARK: Friend Requests
    
    /**
    Sends a friend request to the username provided and notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidSendFriendRequest in case of success
    - EHSystemNotification.SystemDidFailToSendFriendRequest in case of failure
    */
    func sendFriendRequestToUser(user: User)
    {
        let URL = NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + user.username + "/")!
        let request = NSMutableURLRequest(URL: URL)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            let requestFriend = //User(JSONDictionary: JSONResponse as! [String : AnyObject])
            self.outgoingFriendRequests.append(user)
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidSendFriendRequest, object: system, userInfo: nil)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidFailToSendFriendRequest, object: system, userInfo: nil)
            }
        }
    }
    
    /**
    Accepts friend request from the username provided and notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidAcceptFriendRequest in case of success
    - EHSystemNotification.SystemDidFailToAcceptFriendRequest in case of failure
    */
    func acceptFriendRequestFromFriend (requestFriend: User)
    {
        let URL = NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + "/" + requestFriend.username + "/")!
        let request = NSMutableURLRequest(URL: URL)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            self.incomingFriendRequests.removeObject(requestFriend)
            self.fetchUpdatesForFriendsAndFriendSchedules()
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidAcceptFriendRequest, object: system, userInfo: nil)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidFailToAcceptFriendRequest, object: system, userInfo: nil)
            }
        }
    }
    
    /*
    Adds friend from their string encoded representation and notifies via Notification Center.
    The AppUser user is also added as a friend of the friend they are adding, without any approvals from either side.
    
    ### Notifications
    - EHSystemNotification.SystemDidAddFriend in case of success
    */
    func addFriendFromStringEncodedFriendRepresentation (encodedFriend: String) throws
    {
        let mainComponents = encodedFriend.componentsSeparatedByString("\\")
        
        // Get username
        let username = mainComponents[0]
        
        // Get names
        let fullNameComponents = mainComponents[1].componentsSeparatedByString(separationCharacter)
        let firstNames = fullNameComponents[0]
        let lastNames = fullNameComponents[1]
        
        // Get phone number
        let phoneNumber = mainComponents[2]
        
        // Get image
        let imageURL : NSURL? = mainComponents[3].isEmpty ? nil : NSURL(fileURLWithPath: mainComponents[3])
        
        let friend = User(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, ID: username, lastUpdatedOn: NSDate())

        let events = mainComponents[4].isEmpty ? [String]() : mainComponents[4].componentsSeparatedByString(multipleElementsCharacter)
        
        for (i, encodedEvent) in events.enumerate()
        {
            let encodedEventsComponents = encodedEvent.componentsSeparatedByString("-")
            
            // Get event type and weekday
            let eventType : EventType = encodedEventsComponents[0] == "G" ? EventType.FreeTime : EventType.Class
            let weekDay = Int(encodedEventsComponents[1])
            
            // Get Start Date
            let startTimeValues = encodedEventsComponents[2].componentsSeparatedByString(hourMinuteSeparationCharacter)
            let startHourDateComponents = NSDateComponents()
            
            startHourDateComponents.hour = Int(startTimeValues[0])!
            startHourDateComponents.minute = Int(startTimeValues[1])!
            startHourDateComponents.weekday = weekDay!

            // Get End Date
            let endTimeValues = encodedEventsComponents[3].componentsSeparatedByString(hourMinuteSeparationCharacter)
            let endHourDateComponents = NSDateComponents()
            
            endHourDateComponents.hour = Int(endTimeValues[0])!
            endHourDateComponents.minute = Int(endTimeValues[1])!
            endHourDateComponents.weekday = weekDay!
            
            let event = Event(type: eventType, startHour: startHourDateComponents, endHour: endHourDateComponents)
            
            friend.schedule.weekDays[weekDay!].addEvent(event)
        }
        
        friends[friend.username] = friend        
        
        dispatch_async(dispatch_get_main_queue())
        {
            system.appUser.sendFriendRequestToUser(friend)
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidAddFriend, object: system, userInfo: nil)
        }
    }
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

    Returns the string encoded representation of the user, to be decoded by "addFriendFromStringEncodedFriendRepresentation:"
    Formatted as follows:
    username/first names, last names/phone number/imageURL/00:00-00:10,00:30-01:30/00:00-00:10,00:30-01:30
    */
    func stringEncodedUserRepresentation () -> String
    {
        var encodedSchedule = ""

        // Add username
        encodedSchedule += username + splitCharacter
        
        // Add names
        encodedSchedule += firstNames + separationCharacter + lastNames + splitCharacter
        
        // Add phone
        encodedSchedule += String(phoneNumber) + splitCharacter
        
        // Add image
        encodedSchedule += (imageURL?.absoluteString)! + splitCharacter
        
        var firstEvent = true;
        
        // Add events
        for (i, daySchedule) in schedule.weekDays.enumerate() where i > 0
        {
            for (j, event) in daySchedule.events.enumerate()
            {
                if firstEvent
                {
                    firstEvent = false
                }
                else
                {
                    encodedSchedule += multipleElementsCharacter
                }
                
                let eventType = event.type == EventType.FreeTime ? "G" : "C"
                
                // Add event type
                encodedSchedule += eventType + separationCharacter
                
                // Add event weekday
                encodedSchedule += String(i) + separationCharacter
                
                // Add hours
                encodedSchedule += "\(event.startHour.hour)\(hourMinuteSeparationCharacter)\(event.startHour.minute)"
                encodedSchedule += separationCharacter
                encodedSchedule += "\(event.endHour.hour)\(hourMinuteSeparationCharacter)\(event.endHour.minute)"
            }
        }
        
        encodedSchedule += splitCharacter
        
        return encodedSchedule
    }
    
    func isOutdatedBasedOnDate(date: NSDate) -> Bool
    {
        return date.compare(lastUpdatedOn).rawValue > 0
    }
    
    func pushProfilePicture(image: UIImage)
    {
//        let imageData = UIImageJPEGRepresentation(image, 100)
        let url = NSURL(string: EHURLS.Base + EHURLS.MeImageSegment)
        
        let request = NSMutableURLRequest(URL: url!)
        request.setValue(system.appUser.username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(system.appUser.token, forHTTPHeaderField: EHParameters.Token)
        
        request.HTTPMethod = "PUT"
        request.setValue("attachment; filename=upload.jpg", forHTTPHeaderField: "Content-Disposition")
        
        let jpegData = NSData(data: UIImageJPEGRepresentation(image, 100)!)
        request.HTTPBody = jpegData
        
        ConnectionManager.sendAsyncDataRequest(request, onSuccess: { (data) -> () in
        
            self.fetchAppUser()
//            self.persistProfilePictureWithData(jpegData, onSuccess: { () -> () in
//                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveAppUserImage, object: system)
//            })
        
        }, onFailure: { (error) -> () in
            
            print(error)
        })
    }
    
    func downloadProfilePicture()
    {
        if let url = imageURL
        {
            let request = NSMutableURLRequest(URL: url)
            request.setValue(system.appUser.username, forHTTPHeaderField: EHParameters.UserID)
            request.setValue(system.appUser.token, forHTTPHeaderField: EHParameters.Token)
            request.HTTPMethod = "GET"
            
            ConnectionManager.sendAsyncDataRequest(request, onSuccess: { (data) -> () in
                
                self.persistProfilePictureWithData(data, onSuccess: { () -> () in
                    NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveAppUserImage, object: system)
                })
                
            }) { (error) -> () in
                    
                print(error)
            }
        }
    }
    
    func persistProfilePictureWithData(data : NSData, onSuccess: () -> ())
    {
        let path = ImagePersistenceManager.fileInDocumentsDirectory("profile.jpg")
        ImagePersistenceManager.saveImage(data, path: path, onSuccess: onSuccess)
    }
    
    func pushPhoneNumber(newNumber : String)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setValue(username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "PUT"
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: ["phoneNumber":newNumber], onSuccess: { (JSONResponse) -> () in
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveAppUserWasUpdated, object: system)
            }) { (error) -> () in
                print(error)
        }
    }
}

