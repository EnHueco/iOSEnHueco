//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeFriendsManagerDelegate: class {
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendsManagerDelegate)
}

/// Handles operations related to friends information fetching, and adding and deleting friends (including friend requests and searching)
class RealtimeFriendsManager: FirebaseSynchronizable {

    private let appUserID: String

    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] = [:]

    /// Delegate
    weak var delegate: RealtimeFriendsManagerDelegate?

    /// Friend managers with the friend IDs as the key
    private var friendManagers = [String : RealtimeFriendManager]()

    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeFriendsManagerDelegate?) {
        guard let userID = AccountManager.sharedManager.userID else {
            assertionFailure()
            return nil
        }

        self.delegate = delegate
        appUserID = userID
        createFirebaseSubscriptions()
    }

    private func createFirebaseSubscriptions() {

        let friendsReference = FIRDatabase.database().reference().child(FirebasePaths.friends).child(firebaseUser.uid)

        // Observe friend addition
        let friendAddedHandle = friendsReference.observeEventType(.ChildAdded) { [unowned self] (snapshot) in

            let friendID = snapshot.key
            friendManagers[friendID] = RealtimeFriendManager(friendID: friendID, delegate: self)
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

extension RealtimeFriendsManager {

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

extension RealtimeFriendsManager: RealtimeFriendManagerDelegate {

    func realTimeFriendUpdatesManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendManager) {
        delegate?.realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(self)
    }
}

