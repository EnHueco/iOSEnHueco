//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeFriendsManagerDelegate: class {
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeFriendsManager)
}

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class RealtimeFriendsManager: FirebaseSynchronizable {

    /// Friend managers with the friend IDs as the key
    fileprivate var friendManagers = [String : RealtimeUserManager]()
    
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
        let friendAddedHandle = friendsReference.observe(.childAdded) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            let friendID = snapshot.key
            self.friendManagers[friendID] = RealtimeUserManager(userID: friendID, delegate: self)
        }
        
        _trackHandle(friendAddedHandle, forReference: friendsReference)
        
        var friendRemovedHandle: FIRDatabaseHandle!
        
        // Observe friend removal
        friendRemovedHandle = friendsReference.observe(.childRemoved) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            let friendID = snapshot.key
            self.friendManagers[friendID] = nil
            
            /// Thread safety
            DispatchQueue.main.async{
                self.delegate?.realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
            }
        }
        
        _trackHandle(friendRemovedHandle, forReference: friendsReference)
    }
    
    subscript(friendID: String) -> (friend: User?, schedule: Schedule?) {

        get {
            guard let friendManager = friendManagers[friendID] else { return (nil, nil) }
            return (friendManager.user, friendManager.schedule)
        }
    }

    func friendAndSchedules() -> [(friend: User?, schedule: Schedule?)] {

        // #NoPanic We'll see how this works, if it's too costly we'll keep local array copies to speed up the process
        return friendManagers.values.map { ($0.user, $0.schedule) }
    }
}

extension RealtimeFriendsManager {

    /**
     Returns all friends that are currently available.
     - returns: Friends with their current free time periods
     */
    func currentlyAvailableFriends() -> [(friend:User, freeTime:Event)] {

        return friendAndSchedules().flatMap {

            guard let friend = $0.friend, let freeTime = $0.schedule?.currentAndNextFreeTimePeriods().currentFreeTimePeriod else {
                return nil
            }
            
            return (friend, freeTime)
        }
    }

    /**
     Returns all friends that will soon be available.
     - returns: Friends with their current free time period
     */
    func soonAvailableFriendsWithin(_ interval: TimeInterval) -> [(friend:User, freeTime:Event)] {

        let currentDate = Date()

        return friendAndSchedules().flatMap {

            guard let friend = $0.friend, let freeTime = $0.schedule?.currentAndNextFreeTimePeriods().nextFreeTimePeriod, freeTime.startDateInNearestPossibleWeekToDate(currentDate).timeIntervalSinceNow <= interval else {
                    return nil
            }

            return (friend, freeTime)
        }
    }
}

extension RealtimeFriendsManager: RealtimeUserManagerDelegate {

    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeUserManager) {
        delegate?.realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
    }
}

