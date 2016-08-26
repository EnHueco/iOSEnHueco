//
//  FreeTimePeriodsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

/// Handles operations related to the users' current state (i.e. users' availability (EnHueco's core services))

class CurrentStateManager {
    private init() {}

    /*
    /**
     Returns all friends that are currently available and nearby.
     - returns: Friend with their current free time period
     */
    func currentlyAvailableAndNearbyFriends() -> [(friend:User, freeTime:Event)] {
        
        return friends.values.flatMap {
            
            if let freeTime = $0.currentFreeTimePeriod() where $0.isNearby {
                return (friend, freeTime)
            } else {
                return nil
            }
        }
    }
    
    func friendsCurrentlyNearby() -> [User] {
        return enHueco.appUser.friends.values.filter { $0.isNearby }
    }*/
    
    /**
     Posts an instant free time period that everyone sees and that overrides any classes present in the app user's schedule during the instant free time period duration.
     Network operation must succeed immediately or else the newFreeTimePeriod is discarded.
     
     Updates the appUser
     */
    func postInstantFreeTimePeriod(newFreeTimePeriod: Event, completionHandler: BasicCompletionHandler) {

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.ImmediateEventsSegment)!)
        request.HTTPMethod = "PUT"

        var instantEvent: [String:AnyObject] =
        [
                "type": "EVENT",
                "valid_until": newFreeTimePeriod.endDateInNearestPossibleWeekToDate(NSDate()).serverFormattedString(),
        ]

        instantEvent["name"] = newFreeTimePeriod.name
        instantEvent["location"] = newFreeTimePeriod.location

        ConnectionManager.sendAsyncRequest(request, withJSONParams: instantEvent, successCompletionHandler: {
            (JSONResponse) -> () in

            enHueco.appUser.setInivisibilityEndDate(nil)
            enHueco.appUser.schedule.instantFreeTimePeriod = newFreeTimePeriod

            let _ = try? PersistenceManager.sharedManager.persistData()

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }, failureCompletionHandler: {
            (compoundError) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }

    func deleteInstantFreeTimePeriodWithCompletionHandler(completionHandler: BasicCompletionHandler) {

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.ImmediateEventsSegment)!)
        request.HTTPMethod = "PUT"

        let instantEvent =
        [
                "type": "EVENT",
                "valid_until": NSDate().serverFormattedString()
        ]

        ConnectionManager.sendAsyncRequest(request, withJSONParams: instantEvent, successCompletionHandler: {
            (JSONResponse) -> () in

            AppUserInformationManager.sharedManager.fetchUpdatesForAppUserAndScheduleWithCompletionHandler {
                success, error in

                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: true, error: nil)
                }
            }

        }, failureCompletionHandler: {
            (compoundError) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }
}