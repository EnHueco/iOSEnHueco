//
// Created by Diego Montoya Sefair on 8/27/16.
// Copyright (c) 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol RealtimeEventsAndSchedulesManagerDelegate: class {
    func realtimeEventsAndSchedulesManagerDidReceiveScheduleUpdates(manager: RealtimeEventsAndSchedulesManager)
}

/**
Handles operations related to schedule fetching and autoupdating for the app user, getting schedules for common free time periods, importing
schedules from external services, and adding/removing/editing events.
*/
class RealtimeEventsAndSchedulesManager: FirebaseSynchronizable {

    /// The app user's schedule
    private(set) var schedule: Schedule?
    
    /// Delegate
    weak var delegate: RealtimeEventsAndSchedulesManagerDelegate?
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: RealtimeEventsAndSchedulesManagerDelegate?) {
        
        super.init()
        self.delegate = delegate
    }

    override func _createFirebaseSubscriptions() {

        let reference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUserID)
        let handle = reference.observeEventType(.Value) { [unowned self] (snapshot: FIRDataSnapshot) in

            guard let scheduleJSON = snapshot.value as? [[String : AnyObject]], let schedule = try? Schedule(js: scheduleJSON) else {
                return
            }

            self.schedule = schedule
            self.delegate.realtimeEventsAndSchedulesManagerDidReceiveScheduleUpdates(self)
        }

        _trackHandle(handle, forReference: reference)
    }
}

extension RealtimeEventsAndSchedulesManager {
    
    /** Returns a schedule with the common free time periods among the schedules provided and the one of the app user
     Returns nil if no schedule data has been received for the app user yet.
     
     Note: **Only works with repeating days for now**
     */
    func commonFreeTimePeriodsScheduleAmong(schedules: [Schedule]) -> Schedule? {
        
        guard let schedule = self.schedule else {
            return nil
        }
        
        // TODO: Finish
        
        let currentDate = NSDate()
        var commonFreeTimePeriods = [Event]()
        
        guard schedules.count >= 2 else {
            return Schedule(events: [])
        }
        
        for event in (schedule.events.filter { $0.type == .FreeTime }) {
            
            let startHourInCurrentDate = event.startDateInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endDateInNearestPossibleWeekToDate(currentDate)
            
            for friendSchedule in schedules {
                for friendEvent in (friendSchedule.events.filter { $0.type == .FreeTime }) where friendEvent.overlapsWith(event) {
                    
                    let friendStartHourInCurrentDate = friendEvent.startHourInNearestPossibleWeekToDate(currentDate)
                    let friendEndHourInCurrentDate = friendEvent.endHourInNearestPossibleWeekToDate(currentDate)
                    
                    let newStartDate = (startHourInCurrentDate.isBetween(friendStartHourInCurrentDate, and: friendEndHourInCurrentDate) ? event.startDate : friendEvent.startDate)
                    let newEndDate = (endHourInCurrentDate.isBetween(friendStartHourInCurrentDate, and: friendEndHourInCurrentDate) ? event.endDate : friendEvent.endDate)
                    
                    let repetitionDays = event.repetitionDays!.map { friendEvent.repetitionDays!.contains($0) }
                    
                    let commonEvent = BaseEvent(type: .FreeTime, name: nil, location: nil, startDate: newStartDate, endDate: newEndDate, repetitionDays: repetitionDays)
                    commonFreeTimePeriods.append(Event(type: .FreeTime, startHour: newStartHour, endHour: newEndHour))
                }
            }
        }
        
        return Schedule(events: commonFreeTimePeriods)
    }
}