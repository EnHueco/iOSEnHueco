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
    
    private let firebaseUser: FIRUser
    
    /// All references and handles for the references
    private var databaseRefsAndHandles: [(FIRDatabaseReference, FIRDatabaseHandle)] = []
    
    weak var delegate: EventsAndSchedulesManagerDelegate
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?(delegate: EventsAndSchedulesManagerDelegate?) {
        guard let user = FIRAuth.auth()?.currentUser else {
            assertionFailure()
            return nil
        }
        
        self.delegate = delegate
        firebaseUser = user
        createFirebaseSubscriptions()
    }
    
    private func createFirebaseSubscriptions() {
    
        FIRDatabase.database().reference().child(FirebasePaths.schedules).child(firebaseUser.uid).observeEventType(.Value) { [unowned self] (snapshot) in
            
            guard let scheduleJSON = snapshot.value as? [String : AnyObject], let schedule = Schedule(js: schedule) else {
                return
            }
            
            self.schedule = schedule
            self.delegate.eventsAndSchedulesManagerDidReceiveScheduleUpdates(self)
        }
    }
    
    /** Returns a schedule with the common free time periods among the schedules provided and the one of the app user
     Returns nil if no schedule data has been received for the app user yet.
     */
    func commonFreeTimePeriodsScheduleAmong(schedules: [Schedule]) -> Schedule? {
        
        guard let schedule = self.schedule else {
            return nil
        }
        
        // TODO: Finish
        
        let currentDate = NSDate()
        let commonFreeTimePeriodsSchedule = Schedule()
        
        guard schedules.count >= 2 else {
            return commonFreeTimePeriodsSchedule
        }
        
        for i in 1 ..< enHueco.appUser.schedule.weekDays.count {
            var currentCommonFreeTimePeriods = schedules.first!.schedule.weekDays[i].events.filter {
                $0.type == .FreeTime
            }
            
            for j in 1 ..< schedules.count {
                var newCommonFreeTimePeriods = [Event]()
                
                for freeTimePeriod1 in currentCommonFreeTimePeriods {
                    let startHourInCurrentDate1 = freeTimePeriod1.startHourInNearestPossibleWeekToDate(currentDate)
                    let endHourInCurrentDate1 = freeTimePeriod1.endHourInNearestPossibleWeekToDate(currentDate)
                    
                    for freeTimePeriod2 in schedules[j].schedule.weekDays[i].events.filter({ $0.type == .FreeTime }) {
                        let startHourInCurrentDate2 = freeTimePeriod2.startHourInNearestPossibleWeekToDate(currentDate)
                        let endHourInCurrentDate2 = freeTimePeriod2.endHourInNearestPossibleWeekToDate(currentDate)
                        
                        if !(endHourInCurrentDate1 < startHourInCurrentDate2 || startHourInCurrentDate1 > endHourInCurrentDate2) {
                            let newStartHour = (startHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? freeTimePeriod1.startHour : freeTimePeriod2.startHour)
                            let newEndHour = (endHourInCurrentDate1.isBetween(startHourInCurrentDate2, and: endHourInCurrentDate2) ? freeTimePeriod1.endHour : freeTimePeriod2.endHour)
                            
                            newCommonFreeTimePeriods.append(Event(type: .FreeTime, startHour: newStartHour, endHour: newEndHour))
                        }
                    }
                }
                
                currentCommonFreeTimePeriods = newCommonFreeTimePeriods
            }
            
            commonFreeTimePeriodsSchedule.weekDays[i].setEvents(currentCommonFreeTimePeriods)
        }
        
        return commonFreeTimePeriodsSchedule
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
    class func addEventsWithDataFrom(dummyEvents: [BaseEvent], completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }
        
        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(FirebasePaths.schedules).child(firebaseUser.uid)
        
        scheduleReference.observeSingleEventType(.Value) { [unowned self] (snapshot) in
            
            let unknownError = {
                assertionFailure()
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(error: GenericError.UnknownError)
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
                        completionHandler(error: EventsAndSchedulesManagerError.EventsOverlap)
                    }
                    return
                }
            }
            
            do {
                var update = [String : AnyObject]()
                
                for dummyEvent in dummyEvents {
                    update[dummyEvent.id] = try dummyEvent.jsonRepresentation().foundationDictionary
                }
                
                scheduleReference.updateChildValues(update) { (error, _) in
                    
                    dispatch_async(dispatch_get_main_queue()){
                        completionHandler(error: error)
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

        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(FirebasePaths.schedules).child(appUser.uid)
        
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
}

// TODO: Convert to Firebase
extension EventsAndSchedulesManager {

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

    /** Edits the given existing event from the AppUser's schedule if and only if the request is successful.
     
     - parameter existingEvent:     Reference to existing event
     - parameter dummyEvent:        A new event with the values that should be replaced in the existing event.
    */
    class func editEvent(existingEvent: Event, withValuesOfDummyEvent dummyEvent: Event, completionHandler: BasicCompletionHandler) {

        guard let ID = existingEvent.ID else {
            return
        }

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.EventsSegment + ID + "/")!)
        request.HTTPMethod = "PUT"

        ConnectionManager.sendAsyncRequest(request, withJSONParams: dummyEvent.toJSONObject(associatingUser: enHueco.appUser), successCompletionHandler: {
            (JSONResponse) -> () in

            let JSONDictionary = JSONResponse as! [String:AnyObject]

            existingEvent.replaceValuesWithThoseOfTheEvent(Event(JSONDictionary: JSONDictionary))
            existingEvent.lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!

            try? PersistenceManager.sharedManager.persistData()

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }, failureCompletionHandler: {
            error in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error)
            }
        })
    }
}