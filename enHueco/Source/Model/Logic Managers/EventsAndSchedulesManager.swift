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
import Genome

enum EventsAndSchedulesManagerError: EHErrorType {
    case eventsOverlap

    var localizedDescription: String? {

        switch self {
        case .eventsOverlap: return "EventImportOverlapExplanation".localizedUsingGeneralFile()

        default: return nil
        }
    }
}

class EventsAndSchedulesManager: FirebaseLogicManager {

    fileprivate init() {}

    static let sharedManager = EventsAndSchedulesManager()

    /**
     Adds the events given events to the AppUser's schedule if and only if the request is successful.
     
     - parameter dummyEvents:    Dummy events that contain the information of the events that wish to be added
     */
    func addEventsWithDataFrom(_ dummyEvents: [BaseEvent], completionHandler: @escaping (_ addedEventIDs: [String]?, _ error: Error?) -> Void) {
        
        guard let user = (firebaseUser() { (error) in
            completionHandler(nil, error)
        }) else {
            return
        }
        
        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(user.uid)
        
        scheduleReference.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            let unknownError = {
                assertionFailure()
                DispatchQueue.main.async {
                    completionHandler(nil, GenericError.unknownError)
                }
            }
            
            let json = snapshot.value ?? [:]
            
            if !(json is NSNull) {
                
                guard let schedule = try? Schedule(node: json) else {
                    unknownError()
                    return
                }
                
                for dummyEvent in dummyEvents {
                    guard schedule.canAddEvent(dummyEvent) else {
                        DispatchQueue.main.async {
                            completionHandler(nil, EventsAndSchedulesManagerError.eventsOverlap)
                        }
                        return
                    }
                }
            }
            
            var update = [String : Any]()
            
            for dummyEvent in dummyEvents {
                
                let newID = scheduleReference.childByAutoId().key
                let newEvent = Event(userID: user.uid,
                                  id: newID,
                                  type: dummyEvent.type,
                                  name: dummyEvent.name,
                                  location: dummyEvent.location,
                                  startDate: dummyEvent.startDate,
                                  endDate: dummyEvent.endDate,
                                  repeating: dummyEvent.repeating)
                
                guard let eventJSON = (try? newEvent.foundationDictionary()) ?? nil else {
                    unknownError()
                    return
                }
                
                update[newID] = eventJSON
            }
            
            scheduleReference.updateChildValues(update) { (error, _) in
                
                DispatchQueue.main.async{
                    completionHandler(error == nil ? Array(update.keys) : nil, error)
                }
            }
        }
    }
    
    /// Deletes the events with the given IDs
    func deleteEvents(_ IDs: [String], completionHandler: @escaping BasicCompletionHandler) {
        
        guard let appUser = firebaseUser(completionHandler) else { return }

        let scheduleReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid)
        
        var update = [String : Any]()

        for ID in IDs {
            update[ID] = NSNull()
        }
        
        scheduleReference.updateChildValues(update) { (error, _) in
            DispatchQueue.main.async{
                completionHandler(error)
            }
        }
    }
    
    
    /** Edits the given existing event from the AppUser's schedule if and only if the request is successful.
     
     - parameter eventID: The ID of the event to edit
     - parameter intent:  The intent with the values to change
     */
    func editEvent(_ eventID: String, withIntent intent: EventUpdateIntent, completionHandler: @escaping BasicCompletionHandler) {
        
        guard let appUser = firebaseUser(completionHandler) else { return }
        
        let eventReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid).child(eventID)
        
        guard let updateJSON = (try? intent.foundationDictionary()) ?? nil else {
            assertionFailure()
            DispatchQueue.main.async{ completionHandler(GenericError.unknownError) }
            return
        }
        
        eventReference.updateChildValues(updateJSON) { (error, _) in
            DispatchQueue.main.async{
                completionHandler(error)
            }
        }
    }
    
    /// Fetches the event with the given ID
    func fetchEvent(_ id: String, completionHandler: @escaping (_ event: Event?, _ error: Error?) -> Void) {
        
        guard let appUser = firebaseUser({ (error) in
            DispatchQueue.main.async { completionHandler(nil, error) }
        }) else { return }
        
        let eventReference = FIRDatabase.database().reference().child(FirebasePaths.schedules).child(appUser.uid).child(id)

        eventReference.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            guard let valueJSON = snapshot.value, let event = try? Event(node: valueJSON) else {
                DispatchQueue.main.async { completionHandler(nil, GenericError.unknownError) }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(event, nil)
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
    
    class func importScheduleFromCalendar(_ calendar: EKCalendar, generateFreeTimePeriodsBetweenClasses: Bool, completionHandler: BasicCompletionHandler) {
        /*

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
 */
    }
}
