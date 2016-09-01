//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeFriendsManagerDelegate: class {
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendsManager)
}

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class RealtimeFriendsManager: FirebaseSynchronizable {

    /// Friend managers with the friend IDs as the key
    private var friendManagers = [String : RealtimeFriendManager]()
    
    /// Delegate
    weak var delegate: RealtimeFriendsManagerDelegate?
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeFriendsManagerDelegate?) {
        
        super.init()
        self.delegate = delegate
    }
    
    override func _createFirebaseSubscriptions() {

        let friendsReference = FIRDatabase.database().reference().child(FirebasePaths.friends).child(appUserID)
        
        // Observe friend addition
        let friendAddedHandle = friendsReference.observeEventType(.ChildAdded) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            let friendID = snapshot.key
            self.friendManagers[friendID] = RealtimeFriendManager(friendID: friendID, delegate: self)
        }
        
        _trackHandle(friendAddedHandle, forReference: friendsReference)
        
        var friendRemovedHandle: FIRDatabaseHandle!
        
        // Observe friend removal
        friendRemovedHandle = friendsReference.observeEventType(.ChildRemoved) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            let friendID = snapshot.key
            self.friendManagers[friendID] = nil
            
            /// Thread safety
            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
            }
        }
        
        _trackHandle(friendRemovedHandle, forReference: friendsReference)
    }
    
    subscript(friendID: String) -> (friend: User?, schedule: Schedule?) {

        get {
            guard let friendManager = friendManagers[friendID] else { return (nil, nil) }
            return (friendManager.friend, friendManager.schedule)
        }
    }

    func friendAndSchedules() -> [(friend: User?, schedule: Schedule?)] {

        // #NoPanic We'll see how this works, if it's too costly we'll keep local array copies to speed up the process
        return friendManagers.values.map { ($0.friend, $0.schedule) }
    }
}

extension RealtimeFriendsManager {

    /**
     Returns all friends that are currently available.
     - returns: Friends with their current free time periods
     */
    func currentlyAvailableFriends() -> [(friend:User, freeTime:Event)] {

        return friendAndSchedules().flatMap {

            guard let freeTime = $0.schedule?.currentFreeTimePeriod() else { return nil }
            return ($0.friend, freeTime)
        }
    }

    /**
     Returns all friends that will soon be available.
     - returns: Friends with their current free time period
     */
    func soonAvailableFriendsWithin(interval interval: NSTimeInterval) -> [(friend:User, freeTime:Event)] {

        let currentDate = NSDate()

        return friendAndSchedules().flatMap {

            guard let freeTime = $0.schedule?.nextFreeTimePeriod() where freeTime.startHourInNearestPossibleWeekToDate(currentDate).timeIntervalSinceNow <= interval else {
                return nil
            }

            return ($0.friend, freeTime)
        }
    }
}

extension RealtimeFriendsManager: RealtimeFriendManagerDelegate {

    func realtimeFriendManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendManager) {
        delegate?.realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
    }
}

