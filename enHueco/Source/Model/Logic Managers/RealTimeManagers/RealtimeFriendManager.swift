//
//  RealtimeFriendManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/27/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeFriendManagerDelegate: class {
    func realtimeFriendManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendManagerDelegate)
}

/// Handles user and schedule real-time fetching for a given friend
class RealtimeFriendManager: FirebaseSynchronizable {
    
    let friendID: String
    
    private(set) var friend: User?
    private(set) var schedule: Schedule?
    
    /// Delegate
    weak var delegate: RealtimeFriendManagerDelegate?
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeFriendManagerDelegate?) {
        
        super.init?()
        self.delegate = delegate
    }
    
    override func _createFirebaseSubscriptions() {
        
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
        
        _trackHandle(friendHandle, forReference: friendsReference)
        
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
        
        _trackHandle(scheduleHandle, forReference: scheduleReference)
    }
    
    private func notifyChangesIfNeededForFriend(friendID id: String) {
        
        guard friend != nil && schedule != nil else { return }
        
        dispatch_async(dispatch_get_main_queue()){
            delegate?.realtimeFriendManagerDidReceiveFriendOrFriendScheduleUpdates(self)
        }
    }
}