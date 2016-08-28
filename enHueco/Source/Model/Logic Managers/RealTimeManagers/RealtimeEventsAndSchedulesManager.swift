//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeEventsAndSchedulesManagerDelegate: class {
    func realtimeEventsAndSchedulesManagerDidReceiveScheduleUpdates(manager: EventsAndSchedulesManager)
}

/**
Handles operations related to schedule fetching and autoupdating for the app user, getting schedules for common free time periods, importing
schedules from external services, and adding/removing/editing events.
*/
class RealtimeEventsAndSchedulesManager: FirebaseSynchronizable {

    /// The app user's schedule
    private(set) var schedule: Schedule?

    private let appUserID: String

    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] = [:]

    weak var delegate: RealtimeEventsAndSchedulesManagerDelegate

    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeEventsAndSchedulesManagerDelegate?) {
        guard let userID = AccountManager.sharedManager.userID else {
            assertionFailure()
            return nil
        }

        self.delegate = delegate
        appUserID = userID
        createFirebaseSubscriptions()
    }

    private func createFirebaseSubscriptions() {

        let reference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUserID)
        let handle = reference.observeEventType(.Value) { [unowned self] (snapshot) in

            guard let scheduleJSON = snapshot.value as? [[String : AnyObject]], let schedule = try? Schedule(js: schedule) else {
                return
            }

            self.schedule = schedule
            self.delegate.realtimeEventsAndSchedulesManagerDidReceiveScheduleUpdates(self)
        }

        trackHandle(handle, forReference: reference)
    }

    deinit {
        removeFireBaseSubscriptions()
    }
}
