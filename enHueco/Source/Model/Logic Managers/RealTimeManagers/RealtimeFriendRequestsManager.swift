//
//  RealtimeFriendRequestsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/31/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeFriendRequestsManagerDelegate: class {
    func realtimeFriendRequestsManagerDidReceiveFriendRequestUpdates(_ manager: RealtimeFriendRequestsManager)
}

class RealtimeFriendRequestsManager: FirebaseSynchronizable {
    
    /// Delegate
    weak var delegate: RealtimeFriendRequestsManagerDelegate?
    
    fileprivate(set) var receivedFriendRequests = [User]()
    fileprivate(set) var sentFriendRequests = [User]()

    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeFriendRequestsManagerDelegate?) {
        
        super.init()
        self.delegate = delegate
    }
    
    override func _createFirebaseSubscriptions() {
        
        let firebaseReference = FIRDatabase.database().reference()
        
        let sentRequestsReference = firebaseReference.child(FirebasePaths.sentRequests).child(appUserID)
        
        // Observe sent requests
        let sentRequestsHandle = sentRequestsReference.observe(.value) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            guard let ids = snapshot.value as? [String] else { return }
            
            FriendsManager.shared.fetchUsersWithIDs(ids, completionHandler: { (users, error) in
                guard error == nil, let users = users else { return }
                
                self.sentFriendRequests = users
                
                DispatchQueue.main.async {
                    self.delegate?.realtimeFriendRequestsManagerDidReceiveFriendRequestUpdates(self)
                }
            })
        }
        
        _trackHandle(sentRequestsHandle, forReference: sentRequestsReference)
        
        let receivedRequestsReference = firebaseReference.child(FirebasePaths.receivedRequests).child(appUserID)
        
        // Observe sent requests
        let receivedRequestsHandle = receivedRequestsReference.observe(.value) { [unowned self] (snapshot: FIRDataSnapshot) in
            
            guard let ids = snapshot.value as? [String] else { return }
            
            FriendsManager.shared.fetchUsersWithIDs(ids, completionHandler: { (users, error) in
                guard error == nil, let users = users else { return }
                
                self.receivedFriendRequests = users
                
                DispatchQueue.main.async {
                    self.delegate?.realtimeFriendRequestsManagerDidReceiveFriendRequestUpdates(self)
                }
            })
        }
        
        _trackHandle(receivedRequestsHandle, forReference: receivedRequestsReference)
    }
}
