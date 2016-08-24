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
    func friendsManagerDidReceiveFriendOrFriendScheduleUpdates(manager: FriendsManager)
}

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class FriendsManager: FirebaseSynchronizable {
    
    /// Dictionary with all friends as values and friend IDs as the keys
    private(set) var friends = [String : User]()
    
    /// Dictionary with all friend schedules as values and friend IDs as the keys
    private(set) var schedules = [String : Schedule]()
    
    private let firebaseUser: FIRUser
    
    /// All references and handles for the references
    private var databaseRefsAndHandles: [(FIRDatabaseReference, FIRDatabaseHandle)] = []
    
    /// Delegate
    weak var delegate: FriendsManagerDelegate?
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: FriendsManagerDelegate?) {
        guard let user = FIRAuth.auth()?.currentUser else {
            assertionFailure()
            return nil
        }
        
        self.delegate = delegate
        firebaseUser = user
        createFirebaseSubscriptions()
    }
    
    private func createFirebaseSubscriptions() {
        
        FIRDatabase.database().reference().child(FirebasePaths.friends).child(appUser.uid).observeSingleEventOfType(.Value) { [unowned self] (snapshot) in
            
            let friendIDs = (snapshot as! [String : AnyObject]).keys
            
            for friendID in friendIDs {
                
                let friendReference = database.reference().child(FirebasePaths.users).child(friendID)
                let friendHandle = friendReference.observeEventType(.Value) { [unowned self] (friendSnapshot) in
                    
                    guard let friendJSON = scheduleSnapshot.value as? [String : AnyObject],
                          let friend = try? User(js: friendJSON) else {

                        assertionFailure()
                        return
                    }

                    /// Thread safety, dictionaries are structs and therefore copied.
                    dispatch_async(dispatch_get_main_queue()){
                        self.friends[friend.id] = friend
                        notifyChangesIfNeededForFriend(friendID: friend.id)
                    }
                }
                
                databaseRefsAndHandles.append((friendReference, friendHandle))
                
                let scheduleReference = database.reference().child(FirebasePaths.schedules).child(friendID)
                let scheduleHandle = scheduleReference.observeSingleEventOfType(.Value) { [unowned self] (scheduleSnapshot) in
                    
                    guard let scheduleJSON = scheduleSnapshot.value as? [String : AnyObject],
                          let schedule = try? Schedule(js: scheduleJSON) else {

                        assertionFailure()
                        return
                    }
                    
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
        
    private func notifyChangesIfNeededForFriend(friendID id: String) {
        
        guard friends[friend.id] != nil && schedules[friend.id] != nil else { return }
        
        dispatch_async(dispatch_get_main_queue()){
            delegate?.friendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
        }
    }
    
    deinit {
        removeFireBaseSubscriptions()
    }
}

extension FriendsManager {
    
    /**
     Returns all friends that are currently available.
     - returns: Friends with their current free time periods
     */
    func currentlyAvailableFriends() -> [(friend:User, freeTime:Event)] {
        
        return friends.values.flatMap {
            
            guard let freeTime = $0.currentFreeTimePeriod() else { return nil }
            return (friend, freeTime)
        }
    }
    
    /**
     Returns all friends that will soon be available.
     - returns: Friends with their current free time period
     */
    func soonAvailableFriendsWithin(interval interval: NSTimeInterval) -> [(friend:User, freeTime:Event)] {
        
        let currentDate = NSDate()
        
        return friends.values.flatMap {
            
            guard let freeTime = $0.nextFreeTimePeriod() where freeTime.startHourInNearestPossibleWeekToDate(currentDate).timeIntervalSinceNow <= interval else {
                return nil
            }
            
            return (friend, freeTime)
        }
    }
}

extension FriendsManager {
    
    /// Deletes a friend.
    class func deleteFriend(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = FIRAuth.auth()?.currentUser?.uid else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.NotLoggedIn) }
            return
        }

        let update = [
            appUser.uid + "/" + friendID : NSNull(),
            friendID + "/" + appUserID : NSNull()
        ]
        
        FIRDatabase.database().reference().child(FirebasePaths.friends).updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }

    /// Sends a friend request to the username provided and notifies the result via Notification Center.
    class func sendFriendRequestTo(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = FIRAuth.auth()?.currentUser?.uid else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.NotLoggedIn) }
            return
        }
        
        let update = [
            FirebasePaths.sentRequests + "/" + appUserID : friendID,
            FirebasePaths.receivedRequests + "/" + friendID : appUserID
        ]
        
        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    /// Accepts friend request from the friend id provided.
    class func acceptFriendRequestFrom(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = FIRAuth.auth()?.currentUser?.uid else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.NotLoggedIn) }
            return
        }

        let update = [
            FirebasePaths.receivedRequests + "/" + appUserID + "/" + friendID : NSNull(),
            FirebasePaths.sentRequests + "/" + friendID + "/" + appUserID  : NSNull(),
            FirebasePaths.friends + "/" + appUser.uid : friendID,
            FirebasePaths.friends + "/" + friendID : appUserID
        ]

        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    /**
     Performs a search for users based on their name
     
     - parameter searchText:        Text to search
     */
    class func searchUsersWith(searchText searchText: String, institutionID: String, completionHandler: (results:[User]) -> ()) {
        
        guard !searchText.isBlank() else {
            dispatch_async(dispatch_get_main_queue()) { completionHandler(results: [User]()) }
            return
        }
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(institutionID).observeSingleEventOfType(.Value) { (snapshot) in
            
            guard let value = snapshot.value as? [[String : AnyObject]] else {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(results: [User]()) }
                return
            }
            
            let filteredFriendsJSON = value.filter {
                
                let firstNames = ($0[User.JSONKeys.firstNames] as? String) ?? ""
                let lastNames = ($0[User.JSONKeys.lastNames] as? String) ?? ""
                
                for word in [firstNames.componentsSeparatedByString(" "), lastNames.componentsSeparatedByString(" ")] where word.lowercaseString.hasPrefix(searchText.lowercaseString) {
                    return true
                }
                
                return false
            }

            completionHandler(results: try? [User](js: filteredFriendsJSON) ?? [])
        }
    }
}