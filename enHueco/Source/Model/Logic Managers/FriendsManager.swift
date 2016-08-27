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
class FriendsManager: FirebaseSynchronizable, FirebaseLogicManager {
    
    private let firebaseUser: FIRUser
    
    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] = [:]
    
    /// Delegate
    weak var delegate: FriendsManagerDelegate?
    
    /// Friend managers with the friend IDs as the key
    private var friendManagers = [String : FriendManager]()
    
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
        
        let friendsReference = FIRDatabase.database().reference().child(FirebasePaths.friends).child(firebaseUser.uid)
        
        // Observe friend addition
        let friendAddedHandle = friendsReference.observeEventType(.ChildAdded) { [unowned self] (snapshot) in
            
            let friendID = snapshot.key
            let friendManager = FriendManager(friendID: friendID, delegate: self)
        }
        
        trackHandle(friendAddedHandle, forReference: friendsReference)
        
        var friendRemovedHandle: FIRDatabaseHandle!
        
        // Observe friend removal
        friendRemovedHandle = friendsReference.observeEventType(.ChildRemoved) { [unowned self] (snapshot) in
            
            let friendID = snapshot.key
            
            friendManagers[friendID] = nil
            
            /// Thread safety
            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.friendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
            }
        }
        
        trackHandle(friendsHandle, forReference: friendsReference)
    }
    
    subscript(friendID: String) -> (friend: User?, schedule: Schedule?) {
        
        get {
            guard let friendManager = friendManagers[friendID] else { return nil }
            return (friendManager.friend, friendManager.schedule)
        }
    }
    
    func friendAndSchedules() -> [(friend: User?, schedule: Schedule?)] {
        
        // #NoPanic We'll see how this works, if it's too costly we'll keep local array copies to speed up the process
        return friendManagers.values.map { ($0.friend, $0.schedule) }
    }
    
    deinit {
        removeFireBaseSubscriptions()
    }
}

extension FriendsManager: FriendManagerDelegate {
    
    func friendManagerDidReceiveFriendOrFriendScheduleUpdates(manager: FriendManager) {
        delegate?.friendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
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
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }

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
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }
        
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
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }

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