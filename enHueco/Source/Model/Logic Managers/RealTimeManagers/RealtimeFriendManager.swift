//
//  RealtimeFriendManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/27/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeUserManagerDelegate: class {
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeUserManager)
}

/// Handles user and schedule real-time fetching for a given user
class RealtimeUserManager: FirebaseSynchronizable {
    
    let userID: String
    
    private(set) var user: User?
    private(set) var schedule: Schedule?
    
    /// Delegate
    weak var delegate: RealtimeUserManagerDelegate?
    
    /**
     Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
 
     - parameter userID:   The ID of the user to fetch information for (default is the app user's ID)
     */
    init?(userID: String! = AccountManager.sharedManager.userID, delegate: RealtimeUserManagerDelegate?) {
        
        guard userID != nil else { return nil }
        
        self.userID = userID
        self.delegate = delegate
        
        super.init()
    }
    
    override func _createFirebaseSubscriptions() {
        
        let firebaseReference = FIRDatabase.database().reference()
        
        let friendReference = firebaseReference.child(FirebasePaths.users).child(userID)
        let friendHandle = friendReference.observeEventType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            guard let friendJSON = snapshot.value as? [String : AnyObject],
                let friend = try? User(js: friendJSON) else {
                    
                    assertionFailure()
                    return
            }
            
            /// Thread safety, dictionaries are structs and therefore copied.
            dispatch_async(dispatch_get_main_queue()){
                self.user = friend
                self.notifyChangesIfNeeded()
            }
        }
        
        _trackHandle(friendHandle, forReference: friendReference)
        
        let scheduleReference = firebaseReference.child(FirebasePaths.schedules).child(userID)
        let scheduleHandle = scheduleReference.observeEventType(.Value) { [unowned self] (scheduleSnapshot: FIRDataSnapshot) in
            
            guard let scheduleJSON = scheduleSnapshot.value as? [[String : AnyObject]],
                let schedule = try? Schedule(js: scheduleJSON) else {
                    
                    assertionFailure()
                    return
            }
            
            /// Thread safety
            dispatch_async(dispatch_get_main_queue()){
                self.schedule = schedule
                self.notifyChangesIfNeeded()
            }
        }
        
        _trackHandle(scheduleHandle, forReference: scheduleReference)
    }
    
    private func notifyChangesIfNeeded() {
        
        guard user != nil && schedule != nil else { return }
        
        dispatch_async(dispatch_get_main_queue()){
            self.delegate?.realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(self)
        }
    }
}