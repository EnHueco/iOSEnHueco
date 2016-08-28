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
class RealtimePrivacyManager : FirebaseSynchronizable {

    weak var delegate : RealtimePrivacyManagerDelegate?
    private let appUserID: String
    private(set) var settings : PrivacySettings?

    init?(delegate: RealtimePrivacyManagerDelegate) {

        guard let user = AccountManager.sharedManager.userID else {
            assertionFailure()
            return nil
        }

        self.delegate = delegate
        appUserID = appUserID
        createFirebaseSubscriptions()
    }

    private func createFirebaseSubscriptions() {
        FIRDatabase.database().reference().child(FirebasePaths.privacy).child(appUserID).observeEventType(.Value) { [unowned self] (snapshot) in

            guard let userJSON = snapshot.value as? [String : AnyObject],
            let settings = try? PrivacySettings(js: snapshot) else {
                return
            }

            self.settings = settings

            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.realtimePrivacyManagerDidReceivePrivacyUpdates(self)
            }
        }
    }

    deinit {
        removeFirebaseSubscriptions()
    }
}