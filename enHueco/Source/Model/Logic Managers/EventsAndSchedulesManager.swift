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

class EventsAndSchedulesManager: FirebaseLogicManager {

    private init() {}

    static let sharedManager = EventsAndSchedulesManager()

    /**
     Adds the events given events to the AppUser's schedule if and only if the request is successful.
     
     - parameter dummyEvents:    Dummy events that contain the information of the events that wish to be added
     */
    func addEventsWithDataFrom(dummyEvents: [BaseEvent], completionHandler: (addedEventIDs: [String]?, error: ErrorType?) -> Void) {
        
        guard let user = (firebaseUser() { (error) in
            completionHandler(addedEventIDs: nil, error: error)
        }) else {
            return
        }
        
        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(FirebasePaths.schedules).child(user.uid)
        
        scheduleReference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            let unknownError = {
                assertionFailure()
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(addedEventIDs: nil, error: GenericError.UnknownError)
                }
            }
            
            guard let scheduleJSON = snapshot.value as? [String : AnyObject], let schedule = try? Schedule(js: scheduleJSON) else {
                unknownError()
                return
            }
            
            for dummyEvent in dummyEvents {
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
    func deleteEvents(IDs: [String], completionHandler: BasicCompletionHandler) {
        
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
    func editEvent(eventID eventID: String, withIntent intent: EventUpdateIntent, completionHandler: BasicCompletionHandler) {
        
        guard let appUser = firebaseUser(errorHandler: completionHandler) else { return }
        
        let eventReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid).child(eventID)
        
        guard let tmpUpdateJSON = try? intent.jsonRepresentation().foundationDictionary, let updateJSON = tmpUpdateJSON else {
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
    
    /// Fetches the event with the given ID
    func fetchEvent(id id: String, completionHandler: (event: Event?, error: ErrorType?) -> Void) {
        
        guard let appUser = firebaseUser(errorHandler: { (error) in
            dispatch_async(dispatch_get_main_queue()) { completionHandler(event: nil, error: error) }
        }) else { return }
        
        let eventReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid).child(id)

        eventReference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            guard let valueJSON = snapshot.value as? [String : AnyObject], let event = try? Event(js: valueJSON) else {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(event: nil, error: GenericError.UnknownError) }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(event: event, error: nil)
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