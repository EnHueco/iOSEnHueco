//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeAppUserManagerDelegate: class {
    func realtimeAppUserManagerDidReceiveAppUserInformationUpdates(manager: RealtimeAppUserManager)
}

/** Handles fetching and sending of the AppUser's basic information like names, profile picture, username,
 phone number, and schedule. (Friends are not included)
*/
class RealtimeAppUserManager: FirebaseSynchronizable {
    
    private(set) var appUser: User?
    
    /// Delegate
    weak var delegate: RealtimeAppUserManagerDelegate?
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeAppUserManagerDelegate?) {
        
        super.init?()
        self.delegate = delegate
    }

    override func _createFirebaseSubscriptions() {
        
        let reference = FIRDatabase.database().reference().child(FirebasePaths.users).child(appUserID)
        let handle = reference.observeEventType(.Value) { [unowned self] (snapshot) in

            guard let userJSON = snapshot.value as? [String : AnyObject],
            let appUser = try? User(js: snapshot) else {
                return
            }

            self.appUser = appUser

            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.realtimeAppUserManagerDidReceiveAppUserInformationUpdates(self)
            }
        }

        _trackHandle(handle, forReference: reference)
    }
}
