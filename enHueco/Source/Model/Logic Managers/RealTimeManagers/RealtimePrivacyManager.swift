//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimePrivacyManagerDelegate: class {
    func realtimePrivacyManagerDidReceivePrivacyUpdates(manager: RealtimePrivacyManagerDelegate)
}

/// Handles privacy settings
class RealtimePrivacyManager: FirebaseSynchronizable {

    private(set) var settings : PrivacySettings?

    /// Delegate
    weak var delegate: RealtimePrivacyManagerDelegate?
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimePrivacyManagerDelegate?) {
        
        super.init()
        self.delegate = delegate
    }
    
    override func _createFirebaseSubscriptions() {
        
        let reference = FIRDatabase.database().reference().child(FirebasePaths.privacy).child(appUserID)
        let handle = reference.observeEventType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in

            guard let userJSON = snapshot.value as? [String : AnyObject],
            let settings = try? PrivacySettings(js: snapshot) else {
                return
            }

            self.settings = settings

            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.realtimePrivacyManagerDidReceivePrivacyUpdates(self)
            }
        }
        
        _trackHandle(handle, forReference: reference)
    }
}