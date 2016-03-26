//
//  RequestsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class FriendsManager
{
    private static let instance = FriendsManager()

    private init() {}
    
    class func sharedManager() -> FriendsManager
    {
        return instance
    }

    /**
     Fetches full friends and schedule information from the server and notifies the result via Notification Center.
     
     ### Notifications
     - EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates in case of success
     */
    func fetchUpdatesForFriendsAndFriendSchedules()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "GET"
        
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
                
                enHueco.appUser.friends[newFriend.username] = newFriend
            }
            
            try? PersistenceManager.sharedManager().persistData()
            
            dispatch_async(dispatch_get_main_queue()){
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: self, userInfo: nil)
            }
            
        }) { (error) -> () in
                
        }
    }
    
    /// Deletes a friend. If the operation fails the friend is not deleted.
    func deleteFriend(friend: User, completionHandler: BasicCompletionHandler)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + friend.ID + "/")!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "DELETE"
        
        ConnectionManager.sendAsyncDataRequest(request, onSuccess: { (data) -> () in
            
            enHueco.appUser.friends[friend.username] = nil
            
            try? PersistenceManager.sharedManager().persistData()
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error)
            }
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
        request.setEHSessionHeaders()
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (incomingRequestsResponseDictionary) -> () in
            
            var requestFriends = [User]()
            
            for friendJSON in incomingRequestsResponseDictionary as! [[String : AnyObject]]
            {
                requestFriends.append(User(JSONDictionary: friendJSON))
            }
            
            enHueco.appUser.incomingFriendRequests = requestFriends
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendRequestUpdates, object: enHueco, userInfo: nil)
            }
            
            }) { (error) -> () in
        
        }
    }
    
    /**
     Sends a friend request to the username provided and notifies the result via Notification Center.
     
     ### Notifications
     - EHSystemNotification.SystemDidSendFriendRequest in case of success
     - EHSystemNotification.SystemDidFailToSendFriendRequest in case of failure
     */
    func sendFriendRequestToUser(user: User, completionHandler: BasicCompletionHandler)
    {
        let URL = NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + user.ID + "/")!
        let request = NSMutableURLRequest(URL: URL)
        request.setEHSessionHeaders()
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            let requestFriend = //User(JSONDictionary: JSONResponse as! [String : AnyObject])
            enHueco.appUser.outgoingFriendRequests.append(user)
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }) { (error) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    /**
     Accepts friend request from the username provided and notifies the result via Notification Center.
     
     ### Notifications
     - EHSystemNotification.SystemDidAcceptFriendRequest in case of success
     - EHSystemNotification.SystemDidFailToAcceptFriendRequest in case of failure
     */
    func acceptFriendRequestFromFriend (requestFriend: User, completionHandler: BasicCompletionHandler)
    {
        let URL = NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + "/" + requestFriend.ID + "/")!
        let request = NSMutableURLRequest(URL: URL)
        request.setEHSessionHeaders()
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            enHueco.appUser.incomingFriendRequests.removeObject(requestFriend)
            self.fetchUpdatesForFriendsAndFriendSchedules()
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }) { (error) -> () in
                
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(success: false, error: error)
            }
        }
    }
    
    /**
     Performs a search for users based on their name or code
     
     - parameter searchText:        Text to search
     */
    func searchUsersWithText (searchText: String, completionHandler: (results: [User])->())
    {
        guard !searchText.isBlank() else
        {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(results: [User]())
            }
            
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.UsersSegment + searchText)!)
        request.setValue(enHueco.appUser.username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(enHueco.appUser.token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            var userSearchResults = [User]()
            
            for userJSON in JSONResponse as! [[String : AnyObject]]
            {
                userSearchResults.append(User(JSONDictionary: userJSON))
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(results: userSearchResults)
            }
            
            }) { (error) -> () in
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(results: [User]())
                }
        }
    }
    
    /**
     Adds friend from their string encoded representation and notifies via Notification Center.
     The AppUser user is also added as a friend of the friend they are adding, without any approvals from either side.
     
     ### Notifications
     - EHSystemNotification.SystemDidAddFriend in case of success
     */
    func addFriendFromStringEncodedFriendRepresentation (encodedFriend: String) throws
    {
        typealias Characters = UserStringEncodingCharacters
        
        let mainComponents = encodedFriend.componentsSeparatedByString("\\")
        
        // Get username
        let username = mainComponents[0]
        
        // Get names
        let fullNameComponents = mainComponents[1].componentsSeparatedByString(Characters.separationCharacter)
        let firstNames = fullNameComponents[0]
        let lastNames = fullNameComponents[1]
        
        // Get phone number
        let phoneNumber = mainComponents[2]
        
        // Get image
        let imageURL : NSURL? = mainComponents[3].isEmpty ? nil : NSURL(fileURLWithPath: mainComponents[3])
        
        let friend = User(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, ID: username, lastUpdatedOn: NSDate())
        
        let events = mainComponents[4].isEmpty ? [String]() : mainComponents[4].componentsSeparatedByString(Characters.multipleElementsCharacter)
        
        for (i, encodedEvent) in events.enumerate()
        {
            let encodedEventsComponents = encodedEvent.componentsSeparatedByString("-")
            
            // Get event type and weekday
            let eventType : EventType = encodedEventsComponents[0] == "G" ? EventType.FreeTime : EventType.Class
            let weekDay = Int(encodedEventsComponents[1])
            
            // Get Start Date
            let startTimeValues = encodedEventsComponents[2].componentsSeparatedByString(Characters.hourMinuteSeparationCharacter)
            let startHourDateComponents = NSDateComponents()
            
            startHourDateComponents.hour = Int(startTimeValues[0])!
            startHourDateComponents.minute = Int(startTimeValues[1])!
            startHourDateComponents.weekday = weekDay!
            
            // Get End Date
            let endTimeValues = encodedEventsComponents[3].componentsSeparatedByString(Characters.hourMinuteSeparationCharacter)
            let endHourDateComponents = NSDateComponents()
            
            endHourDateComponents.hour = Int(endTimeValues[0])!
            endHourDateComponents.minute = Int(endTimeValues[1])!
            endHourDateComponents.weekday = weekDay!
            
            let event = Event(type: eventType, startHour: startHourDateComponents, endHour: endHourDateComponents)
            
            friend.schedule.weekDays[weekDay!].addEvent(event)
        }
        
        enHueco.appUser.friends[friend.username] = friend
        
        try? PersistenceManager.sharedManager().persistData()
        
        dispatch_async(dispatch_get_main_queue()) {
            
            //TODO :
            //FriendsManager.sharedManager().sendFriendRequestToUser(friend)
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
}