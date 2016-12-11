//
//  RealtimeFriendManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/27/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase
import Genome

protocol RealtimeUserManagerDelegate: class {
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeUserManager)
}

/// Handles user and schedule real-time fetching for a given user
class RealtimeUserManager: FirebaseSynchronizable {
    
    let userID: String
    
    fileprivate(set) var user: User?
    fileprivate(set) var schedule: Schedule?
    
    /// Delegate
    weak var delegate: RealtimeUserManagerDelegate?
    
    /**
     Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
 
     - parameter userID:   The ID of the user to fetch information for (default is the app user's ID)
     */
    init?(userID: String! = AccountManager.shared.userID, delegate: RealtimeUserManagerDelegate?) {
        
        guard userID != nil else { return nil }
        
        self.userID = userID
        self.delegate = delegate
        
        super.init()
    }
    
    override func _createFirebaseSubscriptions() {
        
        let firebaseReference = FIRDatabase.database().reference()
        
        let friendReference = firebaseReference.child(FirebasePaths.users).child(userID)
        let friendHandle = friendReference.observe(.value) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            guard let friendJSON = snapshot.value,
                let friend = try? User(node: friendJSON) else {
                    
                    assertionFailure()
                    return
            }
            
            /// Thread safety, dictionaries are structs and therefore copied.
            DispatchQueue.main.async{
                self.user = friend
                self.notifyChangesIfNeeded()
            }
        }
        
        _trackHandle(friendHandle, forReference: friendReference)
        
        let scheduleReference = firebaseReference.child(FirebasePaths.schedules).child(userID)
        let scheduleHandle = scheduleReference.observe(.value) { [unowned self] (scheduleSnapshot: FIRDataSnapshot) in
            
            guard let scheduleJSON = scheduleSnapshot.value else {
                return
            }
            
            guard let schedule = try? Schedule(node: scheduleJSON) else {
                assertionFailure()
                return
            }
            
            /// Thread safety
            DispatchQueue.main.async{
                self.schedule = schedule
                self.notifyChangesIfNeeded()
            }
        }
        
        _trackHandle(scheduleHandle, forReference: scheduleReference)
    }
    
    fileprivate func notifyChangesIfNeeded() {
        
        guard user != nil && schedule != nil else { return }
        
        DispatchQueue.main.async{
            self.delegate?.realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(self)
        }
    }
}
