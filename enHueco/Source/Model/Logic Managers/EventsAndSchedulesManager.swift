//
//  SchedulesManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import EventKit
import Firebase

enum EventsAndSchedulesManagerError: EHErrorType {
    case EventsOverlap

    var localizedDescription: String? {

        switch self {
        case .EventsOverlap: return "EventImportOverlapExplanation".localizedUsingGeneralFile()

        default: return nil
        }
    }
}

protocol EventsAndSchedulesManagerDelegate: class {
    func eventsAndSchedulesManagerDidReceiveScheduleUpdates(manager: EventsAndSchedulesManager)
}

/** 
Handles operations related to schedule fetching and autoupdating for the app user, getting schedules for common free time periods, importing
schedules from external services, and adding/removing/editing events.
*/
class EventsAndSchedulesManager: FirebaseSynchronizable, FirebaseLogicManager {
    
    /// The app user's schedule
    private(set) var schedule: Schedule?
    
    private let appUserID: String
    
    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] = [:]
    
    weak var delegate: EventsAndSchedulesManagerDelegate
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: EventsAndSchedulesManagerDelegate?) {
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
            
            guard let scheduleJSON = snapshot.value as? [[String : AnyObject]], let schedule = Schedule(js: schedule) else {
                return
            }
            
            self.schedule = schedule
            self.delegate.eventsAndSchedulesManagerDidReceiveScheduleUpdates(self)
        }
        
        trackHandle(handle, forReference: reference)
    }
    
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
            return commonFreeTimePeriodsSchedule
        }
        
        for event in (schedule.events.filter { $0.type == .FreeTime }) {
            
            let startHourInCurrentDate = event.startHourInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endHourInNearestPossibleWeekToDate(currentDate)
            
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
    
    deinit {
        removeFireBaseSubscriptions()
    }
}

extension EventsAndSchedulesManager {
    
    /**
     Adds the events given events to the AppUser's schedule if and only if the request is successful.
     
     - parameter dummyEvents:    Dummy events that contain the information of the events that wish to be added
     */
    class func addEventsWithDataFrom(dummyEvents: [BaseEvent], completionHandler: (addedEventIDs: [String]?, error: ErrorType?) -> Void) {
        
        guard let user = (firebaseUser() { (error) in
            completionHandler(addedEventIDs: nil, error: error)
        }) else {
            return
        }
        
        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(FirebasePaths.schedules).child(appUser.uid)
        
        scheduleReference.observeSingleEventType(.Value) { [unowned self] (snapshot) in
            
            let unknownError = {
                assertionFailure()
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(addedEventIDs: nil, error: GenericError.UnknownError)
                }
            }
            
            guard let scheduleJSON = snapshot.value as? [String : AnyObject], let schedule = try? Schedule(js: schedule) else {
                unknownError()
                return
            }
            
            for dummyEvent in dummyEvents {
                
                let localWeekDay = localCalendar.component(.Weekday, fromDate: dummyEvent.startDate)
                
                guard schedule.canAddEvent(dummyEvent) else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(addedEventIDs: nil, error: EventsAndSchedulesManagerError.EventsOverlap)
                    }
                    return
                }
            }
            
            do {
                var update = [String : AnyObject]()
                
                for dummyEvent in dummyEvents {
                    let newID = scheduleReference.childByAutoId().key
                    update[newID] = try dummyEvent.jsonRepresentation().foundationDictionary
                }
                
                scheduleReference.updateChildValues(update) { (error, _) in
                    
                    dispatch_async(dispatch_get_main_queue()){
                        completionHandler(addedEventIDs: error == nil ? Array(update.keys) : nil, error: error)
                    }
                }
                
            } catch {
                unknownError()
            }
        }
    }
    
    /// Deletes the events with the given IDs
    class func deleteEvents(IDs: [String], completionHandler: BasicCompletionHandler) {
        
        guard let appUser = firebaseUser(errorHandler: completionHandler) else { return }

        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid)
        
        var update = [String : AnyObject]()

        for ID in IDs {
            update[ID] = NSNull()
        }
        
        scheduleReference.updateChildValues(update) { (error, _) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    
    /** Edits the given existing event from the AppUser's schedule if and only if the request is successful.
     
     - parameter eventID: The ID of the event to edit
     - parameter intent:  The intent with the values to change
     */
    class func editEvent(eventID eventID: String, withIntent intent: Event, completionHandler: BasicCompletionHandler) {
        
        guard let appUser = firebaseUser(errorHandler: completionHandler) else { return }
        
        let eventReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid).child(eventID)
        
        guard let updateJSON = try? intent.jsonRepresentation().foundationDictionary else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.UnknownError) }
            return
        }
        
        eventReference.updateChildValues(updateJSON) { (error, _) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
}

// TODO: Convert to Firebase
extension EventsAndSchedulesManager {

    /*
    /**
     Imports an schedule of classes from a device's calendar.
     - parameter generateFreeTimePeriodsBetweenClasses: If gaps between classes should be calculated and added to the schedule.
     */
    class func importScheduleFromCalendar(calendar: EKCalendar, generateFreeTimePeriodsBetweenClasses: Bool, completionHandler: BasicCompletionHandler) {

        let today = NSDate()
        let eventStore = EKEventStore()

        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        let componentUnits: NSCalendarUnit = [.Year, .WeekOfYear, .Weekday, .Hour, .Minute, .Second]
        var components = localCalendar.components(componentUnits, fromDate: today)

        components.weekday = 6
        components.hour = 23
        components.minute = 59
        components.second = 59

        let nextFridayAtEndOfDay = localCalendar.dateFromComponents(components)!

        components = localCalendar.components(componentUnits, fromDate: today)

        components.weekday = 2
        components.hour = 0
        components.minute = 0
        components.second = 0

        let lastMondayAtStartOfDay = localCalendar.dateFromComponents(components)!

        let calendars = [calendar]

        let fetchEventsPredicate = eventStore.predicateForEventsWithStartDate(lastMondayAtStartOfDay, endDate: nextFridayAtEndOfDay, calendars: calendars)
        let fetchedEvents = eventStore.eventsMatchingPredicate(fetchEventsPredicate)

        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!

        let classEvents = fetchedEvents.map {
            fetchedEvent -> Event in

            let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]

            let startDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: fetchedEvent.startDate)
            let endDateComponents = globalCalendar.components(weekdayHourMinute, fromDate: fetchedEvent.endDate)

            return Event(type: .Class, name: fetchedEvent.title, startHour: startDateComponents, endHour: endDateComponents, location: fetchedEvent.location)
        }

        do {
            try EventsAndSchedulesManager.sharedManager.addEventsWithDataFromEvents(classEvents) {
                (addedEvents, error) in

                guard addedEvents != nil && error == nil else {
                    completionHandler(success: false, error: error)
                    return
                }

                if generateFreeTimePeriodsBetweenClasses {
                    //TODO: Calculate Gaps and add them
                }

                completionHandler(success: true, error: nil)
            }
        } catch {
            completionHandler(success: false, error: error)
        }
    }
    */
}