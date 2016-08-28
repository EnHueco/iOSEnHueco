//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeAppUserManagerDelegate: class {
    func realtimeAppUserManagerDidReceiveAppUserInformationUpdates(manager: AppUserManager)
}

/** Handles fetching and sending of the AppUser's basic information like names, profile picture, username,
 phone number, and schedule. (Friends are not included)
*/
class RealtimeAppUserManager: FirebaseSynchronizable {

    /// Delegate
    weak var delegate: RealtimeAppUserManagerDelegate?

    private let appUserID: String

    private(set) var appUser: User?

    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] = [:]

    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeAppUserManagerDelegate?) {
        guard let userID = AccountManager.sharedManager.userID else {
            assertionFailure()
            return nil
        }

        self.delegate = delegate
        appUserID = userID
        createFirebaseSubscriptions()
    }

    private func createFirebaseSubscriptions() {

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

        trackHandle(handle, forReference: reference)
    }

    deinit {
        removeFirebaseSubscriptions()
    }
}
