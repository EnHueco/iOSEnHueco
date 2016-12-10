//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase
import Genome

protocol RealtimePrivacyManagerDelegate: class {
    func realtimePrivacyManagerDidReceivePrivacyUpdates(_ manager: RealtimePrivacyManager)
}

/// Handles privacy settings
class RealtimePrivacyManager: FirebaseSynchronizable {

    fileprivate(set) var settings : PrivacySettings?

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
        let handle = reference.observe(.value) { [unowned self] (snapshot: FIRDataSnapshot) in

            guard let json = snapshot.value,
                let settings = try? PrivacySettings(node: json) else {
                return
            }

            self.settings = settings

            DispatchQueue.main.async{
                self.delegate?.realtimePrivacyManagerDidReceivePrivacyUpdates(self)
            }
        }
        
        _trackHandle(handle, forReference: reference)
    }
}
