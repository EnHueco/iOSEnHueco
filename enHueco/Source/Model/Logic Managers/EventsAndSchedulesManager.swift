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
    case CantAddEvents

    var localizedDescription: String? {

        switch self {
        case .CantAddEvents: return "EventImportOverlapExplanation".localizedUsingGeneralFile()

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
class EventsAndSchedulesManager: FirebaseSynchronizable {
    
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
    
    deinit {
        removeFireBaseSubscriptions()
    }
}

extension EventsAndSchedulesManager {

    /**
     Returns a schedule with the common free time periods of the users provided.
     */
    class func commonFreeTimePeriodsScheduleForUsers(users: [User]) -> Schedule {

        let currentDate = NSDate()
        let commonFreeTimePeriodsSchedule = Schedule()

        guard users.count >= 2 else {
            return commonFreeTimePeriodsSchedule
        }

        for i in 1 ..< enHueco.appUser.schedule.weekDays.count {
            var currentCommonFreeTimePeriods = users.first!.schedule.weekDays[i].events.filter {
                $0.type == .FreeTime
            }

            for j in 1 ..< users.count {
                var newCommonFreeTimePeriods = [Event]()

                for freeTimePeriod1 in currentCommonFreeTimePeriods {
                    let startHourInCurrentDate1 = freeTimePeriod1.startHourInNearestPossibleWeekToDate(currentDate)
                    let endHourInCurrentDate1 = freeTimePeriod1.endHourInNearestPossibleWeekToDate(currentDate)

                    for freeTimePeriod2 in users[j].schedule.weekDays[i].events.filter({ $0.type == .FreeTime }) {
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

    /**
     Adds the events given events to the AppUser's schedule if and only if the request is successful.
     
     - parameter dummyEvents:    Dummy events that contain the information of the events that wish to be added
     - throws: CantAddEvents in case new events overlap with existing events. The request is not attempted.
     */
    class func addEventsWithDataFrom(dummyEvents: [BaseEvent], completionHandler: BasicCompletionHandler) throws {

        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }
        
        let scheduleRef = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(firebaseUser.uid)
        
        scheduleRef.observeSingleEventType(.Value) { [unowned self] (snapshot) in
            
            guard let scheduleJSON = snapshot.value as? [String : AnyObject], let schedule = Schedule(js: schedule) else {
                assertionFailure()
                dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.NotLoggedIn) }
                return
            }
            
            for dummyEvent in dummyEvents {
                
                let localWeekDay = localCalendar.component(.Weekday, fromDate: dummyEvent.startDate)
                
                guard schedule.canAddEvent(dummyEvent) || dummyEvent.repetitionDays == nil else {
                    throw EventsAndSchedulesManagerError.CantAddEvents
                }
            }
            
            do {
                let params = dummyEvents.map {
                    try $0.jsonRepresentation().foundationDictionary
                }
                
                
                
            } catch {
                
            }
            
            ///TODO: Finish
        }
    }

    /** Deletes the given existing events from the AppUser's schedule if and only if the request is successful.
     The events given **must** be a reference to existing events.
    */
    class func deleteEvents(existingEvents: [Event], completionHandler: BasicCompletionHandler) {

        guard existingEvents.reduce(true, combine: { $0 && $1.ID != nil }) else {
            return
        }

        let params = existingEvents.map {
            ["id": $0.ID]
        }

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.EventsSegment)!)
        request.HTTPMethod = "DELETE"

        ConnectionManager.sendAsyncDataRequest(request, withJSONParams: params, successCompletionHandler: {
            (_) -> () in

            for event in existingEvents {
                enHueco.appUser.schedule.removeEventWithID(event.ID)
            }

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