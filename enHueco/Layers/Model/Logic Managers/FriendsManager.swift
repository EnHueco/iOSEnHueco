//
//  RequestsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

class FriendsManagerNotification
{
    static let didReceiveFriendAndScheduleUpdates = "didReceiveFriendAndScheduleUpdates"
    static let didReceiveFriendRequestUpdates = "didReceiveFriendRequestUpdates"
}

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class FriendsManager
{
    static let sharedManager = FriendsManager()

    private init() {}
    
    
    func fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(completionHandler: BasicCompletionHandler?)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSyncSegment)!)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: { (response) -> () in
            
            var friendsToUpdate = [[String: AnyObject]]()
            var allFriendsJSONDict : [String:Bool] = [:]
            
            for friendJSON in response as! [[String: AnyObject]]
            {
                let newFriend = UserSync(JSONDictionary: friendJSON)
                allFriendsJSONDict[newFriend.username] = true
                
                let friendExists = enHueco.appUser.friends[newFriend.username] != nil
                var friendOutdated = false
                
                // Check if outdated
                if friendExists
                {
                    let friend = enHueco.appUser.friends[newFriend.username]!
                    
                    friendOutdated = newFriend.lastUpdatedOn > friend.lastUpdatedOn
                }
                
                // if newFriend hasn't been downloaded or is updated
                if !friendExists || friendOutdated
                {
                    friendsToUpdate.append(newFriend.toJSONDictionary())
                }
            }
            
            // Friend deletion
            
            var deleted = false
            for (friendUsername, friend) in enHueco.appUser.friends
            {
                if allFriendsJSONDict[friendUsername] == nil
                {
                    enHueco.appUser.friends[friendUsername] = nil
                    deleted = true
                }
            }
            
            if deleted
            {
                try? PersistenceManager.sharedManager.persistData()
                
                dispatch_async(dispatch_get_main_queue()){
                    
                    completionHandler?(success: true, error: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(FriendsManagerNotification.didReceiveFriendAndScheduleUpdates, object: self, userInfo: nil)
                }
            }
            
            if friendsToUpdate.count != 0
            {
                self._fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(completionHandler, friendsToRequest: friendsToUpdate)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()){
                completionHandler?(success: false, error: error)
            }
        }
    }
    
    /**
     Fetches full friends and schedule information from the server and notifies the result via Notification Center.
     
     ### Notifications
     - EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates in case of success
     */
    private func _fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(completionHandler: BasicCompletionHandler?, friendsToRequest : [[String : AnyObject]])
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment)!)
        
        
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: friendsToRequest, successCompletionHandler: { (response) -> () in
            
            let globalCalendar = NSCalendar.currentCalendar()
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!
            
            let friendsJSONArray = response as! [[String: AnyObject]]
            
            var friendsJSONDict : [String:Bool] = [:]
            
            // Add and update friends
            for friendJSON in friendsJSONArray
            {
                let newFriend = User(JSONDictionary: friendJSON)
                
                enHueco.appUser.friends[newFriend.username] = newFriend
                friendsJSONDict[newFriend.username] = true
            }
            
            try? PersistenceManager.sharedManager.persistData()
            
            dispatch_async(dispatch_get_main_queue()){
                
                completionHandler?(success: true, error: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(FriendsManagerNotification.didReceiveFriendAndScheduleUpdates, object: self, userInfo: nil)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()){
                completionHandler?(success: false, error: error)
            }
        }
    }
    
    /// Deletes a friend. If the operation fails the friend is not deleted.
    func deleteFriend(friend: User, completionHandler: BasicCompletionHandler)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + friend.ID + "/")!)
        request.HTTPMethod = "DELETE"
        
        ConnectionManager.sendAsyncDataRequest(request, successCompletionHandler: { (data) -> () in
            
            enHueco.appUser.friends[friend.username] = nil
            
            try? PersistenceManager.sharedManager.persistData()
            
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
    func fetchUpdatesForFriendRequestsWithCompletionHandler(completionHandler: BasicCompletionHandler?)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.IncomingFriendRequestsSegment)!)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: { (incomingRequestsResponseDictionary) -> () in
            
            var requestFriends = [User]()
            
            for friendJSON in incomingRequestsResponseDictionary as! [[String : AnyObject]]
            {
                requestFriends.append(User(JSONDictionary: friendJSON))
            }
            
            enHueco.appUser.incomingFriendRequests = requestFriends
            
            try? PersistenceManager.sharedManager.persistData()
            
            dispatch_async(dispatch_get_main_queue()) {
                
                completionHandler?(success: true, error: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(FriendsManagerNotification.didReceiveFriendRequestUpdates, object: self, userInfo: nil)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()){
                completionHandler?(success: false, error: error)
            }
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
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: { (JSONResponse) -> () in
            
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
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: { (JSONResponse) -> () in
            
            enHueco.appUser.incomingFriendRequests.removeObject(requestFriend)
            let userDataRequest = [UserSync(fromUser: requestFriend).toJSONDictionary()]
            self._fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(nil, friendsToRequest: userDataRequest)
                        
            try? PersistenceManager.sharedManager.persistData()

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
        guard let urlString = (EHURLS.Base + EHURLS.UsersSegment + searchText).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
              let url = NSURL(string: urlString)
            where !searchText.isBlank() else
        {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(results: [User]())
            }
            
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: { (JSONResponse) -> () in
            
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
        
        let imageThumbnailURL : NSURL? = mainComponents[4].isEmpty ? nil : NSURL(fileURLWithPath: mainComponents[4])
        
        let friend = User(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, imageThumbnailURL : imageThumbnailURL, ID: username, lastUpdatedOn: NSDate())
        
        let events = mainComponents[5].isEmpty ? [String]() : mainComponents[4].componentsSeparatedByString(Characters.multipleElementsCharacter)
        
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
        
        try? PersistenceManager.sharedManager.persistData()
        
        dispatch_async(dispatch_get_main_queue()) {
            
            //TODO :
            //FriendsManager.sharedManager.sendFriendRequestToUser(friend)
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