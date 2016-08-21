//
//  RequestsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

protocol FriendsManagerDelegate: class {
    func friendsManagerDidReceiveUpdates(manager: FriendsManager)
}

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class FriendsManager: NetworkSynchronizable {
    
    /// Dictionary with all friends as values and friend IDs as the keys
    private(set) var friends = [String : User]()
    
    /// Dictionary with all friend schedules as values and friend IDs as the keys
    private(set) var schedules = [String : Schedule]()

    weak var delegate: FriendsManagerDelegate?
    
    private let appUser: FIRUser
    
    /// All references and handles for the references
    private var databaseRefsAndHandles = [(FIRDatabaseReference, FIRDatabaseHandle)]()
    
    private let database = FIRDatabase.database()

    init?() {
        
        guard let appUser = FIRAuth.auth()?.currentUser else {
            assertionFailure()
            return nil
        }

        self.appUser = appUser
    }

    func resumeUpdates() {
        
        database.referenceWithPath("\(FirebasePaths.friends).\(appUser.uid)").observeSingleEventOfType(.Value) { [unowned self] (snapshot) in
            
            let friendIDs = (snapshot as! [String : AnyObject]).keys
            
            for friendID in friendIDs {
                
                let friendReference = database.referenceWithPath("\(FirebasePaths.users).\(friendID)")
                let friendHandle = friendReference.observeEventType(.Value) { [unowned self] (friendSnapshot) in

                    guard let friendJSON = scheduleSnapshot.value as? [String : AnyObject] else { return }
                    let friend = User(js: friendJSON)

                    /// Thread safety, dictionaries are structs and therefore copied.
                    dispatch_async(dispatch_get_main_queue()){
                        self.friends[friend.id] = friend
                        notifyChangesIfNeededForFriend(friendID: friend.id)
                    }
                }
                
                databaseRefsAndHandles.append((friendReference, friendHandle))

                let scheduleReference = database.referenceWithPath("\(FirebasePaths.schedules).\(friendID)")
                let scheduleHandle = scheduleReference.observeSingleEventOfType(.Value) { [unowned self] (scheduleSnapshot) in

                    guard let scheduleJSON = scheduleSnapshot.value as? [String : AnyObject] else { return }
                    let schedule = Schedule(js: scheduleJSON)
                    
                    /// Thread safety
                    dispatch_async(dispatch_get_main_queue()){
                        self.schedules[friend.id] = schedule
                        notifyChangesIfNeededForFriend(friendID: friend.id)
                    }
                }
                
                databaseRefsAndHandles.append((scheduleReference, scheduleHandle))
            }
        }
        
    }

    func stopUpdates() {
        
        for (ref, handle) in databaseRefsAndHandles {
            ref.removeObserverWithHandle(handle)
        }
    }
    
    private func notifyChangesIfNeededForFriend(friendID id: String) {
        
        guard friends[friend.id] != nil && schedules[friend.id] != nil else { return }
        
        dispatch_async(dispatch_get_main_queue()){
            delegate?.friendsManagerDidReceiveUpdates(self)
        }
    }

    /*
    private func fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(completionHandler: BasicCompletionHandler?) {

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSyncSegment)!)
        request.HTTPMethod = "GET"

        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: {
            (response) -> () in

            var friendsToUpdate = [[String: AnyObject]]()
            var allFriendsJSONDict: [String:Bool] = [:]

            for friendJSON in response as! [[String:AnyObject]] {
                let newFriend = UserSync(JSONDictionary: friendJSON)
                allFriendsJSONDict[newFriend.username] = true

                let friendExists = enHueco.appUser.friends[newFriend.username] != nil
                var friendOutdated = false

                // Check if outdated
                if friendExists {
                    let friend = enHueco.appUser.friends[newFriend.username]!

                    friendOutdated = newFriend.lastUpdatedOn > friend.lastUpdatedOn
                }

                // if newFriend hasn't been downloaded or is updated
                if !friendExists || friendOutdated {
                    friendsToUpdate.append(newFriend.toJSONDictionary())
                }
            }

            // Friend deletion

            var deleted = false
            for (friendUsername, friend) in enHueco.appUser.friends {
                if allFriendsJSONDict[friendUsername] == nil {
                    enHueco.appUser.friends[friendUsername] = nil
                    deleted = true
                }
            }

            if deleted {
                try? PersistenceManager.sharedManager.persistData()

                dispatch_async(dispatch_get_main_queue()) {

                    completionHandler?(success: true, error: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(FriendsManagerNotification.didReceiveFriendAndScheduleUpdates, object: self, userInfo: nil)
                }
            }

            if friendsToUpdate.count != 0 {
                self._fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(completionHandler, friendsToRequest: friendsToUpdate)
            }

        }) {
            (error) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: false, error: error)
            }
        }
    }

    /**
     Fetches full friends and schedule information from the server and notifies the result via Notification Center.
     
     ### Notifications
     - EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates in case of success
     */
    private func _fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(completionHandler: BasicCompletionHandler?, friendsToRequest: [[String:AnyObject]]) {

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment)!)


        request.HTTPMethod = "POST"

        ConnectionManager.sendAsyncRequest(request, withJSONParams: friendsToRequest, successCompletionHandler: {
            (response) -> () in

            let globalCalendar = NSCalendar.currentCalendar()
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!

            let friendsJSONArray = response as! [[String:AnyObject]]

            var friendsJSONDict: [String:Bool] = [:]

            // Add and update friends
            for friendJSON in friendsJSONArray {
                let newFriend = User(JSONDictionary: friendJSON)

                enHueco.appUser.friends[newFriend.username] = newFriend
                friendsJSONDict[newFriend.username] = true
            }

            try? PersistenceManager.sharedManager.persistData()

            dispatch_async(dispatch_get_main_queue()) {

                completionHandler?(success: true, error: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(FriendsManagerNotification.didReceiveFriendAndScheduleUpdates, object: self, userInfo: nil)
            }

        }) {
            (error) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: false, error: error)
            }
        }
    }

    /// Deletes a friend. If the operation fails the friend is not deleted.
    class func deleteFriend(friend: User, completionHandler: BasicCompletionHandler) {

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + friend.ID + "/")!)
        request.HTTPMethod = "DELETE"

        ConnectionManager.sendAsyncDataRequest(request, successCompletionHandler: {
            (data) -> () in

            enHueco.appUser.friends[friend.username] = nil

            try? PersistenceManager.sharedManager.persistData()

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }) {
            (error) -> () in

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
    private func fetchUpdatesForFriendRequestsWithCompletionHandler(completionHandler: BasicCompletionHandler?) {

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.IncomingFriendRequestsSegment)!)
        request.HTTPMethod = "GET"

        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: {
            (incomingRequestsResponseDictionary) -> () in

            var requestFriends = [User]()

            for friendJSON in incomingRequestsResponseDictionary as! [[String:AnyObject]] {
                requestFriends.append(User(JSONDictionary: friendJSON))
            }

            enHueco.appUser.incomingFriendRequests = requestFriends

            try? PersistenceManager.sharedManager.persistData()

            dispatch_async(dispatch_get_main_queue()) {

                completionHandler?(success: true, error: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(FriendsManagerNotification.didReceiveFriendRequestUpdates, object: self, userInfo: nil)
            }

        }) {
            (error) -> () in

            dispatch_async(dispatch_get_main_queue()) {
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
    private func sendFriendRequestToUser(user: User, completionHandler: BasicCompletionHandler) {

        let URL = NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + user.ID + "/")!
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"

        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: {
            (JSONResponse) -> () in

            let requestFriend = //User(JSONDictionary: JSONResponse as! [String : AnyObject])
            enHueco.appUser.outgoingFriendRequests.append(user)

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }) {
            (error) -> () in

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
    private func acceptFriendRequestFromFriend(requestFriend: User, completionHandler: BasicCompletionHandler) {

        let URL = NSURL(string: EHURLS.Base + EHURLS.FriendsSegment + requestFriend.ID + "/")!
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"

        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: {
            (JSONResponse) -> () in

            enHueco.appUser.incomingFriendRequests.removeObject(requestFriend)
            let userDataRequest = [UserSync(fromUser: requestFriend).toJSONDictionary()]
            self._fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(nil, friendsToRequest: userDataRequest)

            try? PersistenceManager.sharedManager.persistData()

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }) {
            (error) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error)
            }
        }
    }

    /**
     Performs a search for users based on their name or code
     
     - parameter searchText:        Text to search
     */
    class func searchUsersWithText(searchText: String, completionHandler: (results:[User]) -> ()) {

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

        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: {
            (JSONResponse) -> () in

            var userSearchResults = [User]()

            for userJSON in JSONResponse as! [[String:AnyObject]] {
                userSearchResults.append(User(JSONDictionary: userJSON))
            }

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(results: userSearchResults)
            }

        }) {
            (error) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(results: [User]())
            }
        }
    }
 */
}