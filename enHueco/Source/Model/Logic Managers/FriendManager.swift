//
//  FriendManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/27/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation

protocol FriendManagerDelegate: class {
    func friendManagerDidReceiveFriendOrFriendScheduleUpdates(manager: FriendManager)
}

/// Handles user and schedule real-time fetching for a given friend
class FriendManager: FirebaseSynchronizable, FirebaseLogicManager {
    
    weak var delegate: FriendManagerDelegate?
    
    let friendID: String
    
    private(set) var friend: User?
    private(set) var schedule: Schedule?
    
    private let appUserID: String
    
    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] = [:]
    
    init?(friendID: String, delegate: FriendManagerDelegate?) {
        guard let userID = AccountManager.sharedManager.userID else {
            assertionFailure()
            return nil
        }

        self.friendID = friendID
        self.delegate = delegate
        appUserID = userID
        createFirebaseSubscriptions()
    }
    
    private func createFirebaseSubscriptions() {
        
        let friendReference = database.reference().child(FirebasePaths.users).child(friendID)
        let friendHandle = friendReference.observeEventType(.Value) { [unowned self] (friendSnapshot) in
            
            guard let friendJSON = scheduleSnapshot.value as? [String : AnyObject],
                let friend = try? User(js: friendJSON) else {
                    
                    assertionFailure()
                    return
            }
            
            /// Thread safety, dictionaries are structs and therefore copied.
            dispatch_async(dispatch_get_main_queue()){
                self.friend = friend
                notifyChangesIfNeeded()
            }
        }
        
        trackHandle(friendHandle, forReference: friendsReference)
        
        let scheduleReference = database.reference().child(FirebasePaths.schedules).child(friendID)
        let scheduleHandle = scheduleReference.observeSingleEventOfType(.Value) { [unowned self] (scheduleSnapshot) in
            
            guard let scheduleJSON = scheduleSnapshot.value as? [[String : AnyObject]],
                let schedule = try? Schedule(js: scheduleJSON) else {
                    
                    assertionFailure()
                    return
            }
            
            /// Thread safety
            dispatch_async(dispatch_get_main_queue()){
                self.schedule = schedule
                notifyChangesIfNeeded()
            }
        }
        
        trackHandle(scheduleHandle, forReference: scheduleReference)
    }
    
    private func notifyChangesIfNeededForFriend(friendID id: String) {
        
        guard friend != nil && schedule != nil else { return }
        
        dispatch_async(dispatch_get_main_queue()){
            delegate?.friendManagerDidReceiveFriendOrFriendScheduleUpdates(self)
        }
    }
    
    deinit {
        removeFirebaseSubscriptions()
    }
}