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
    static let sharedManager = CurrentStateManager()

    private init() {
    }

    /**
     Returns all friends that are currently available and nearby.
     - returns: Friend with their current free time period
     */
    func currentlyAvailableAndNearbyFriends() -> [(friend:User, freeTime:Event)] {

        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()

        for friend in enHueco.appUser.friends.values {
            if let freeTime = friend.currentFreeTimePeriod() where friend.isNearby {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }

        return friendsAndFreeTimePeriods
    }

    func friendsCurrentlyNearby() -> [User] {

        return enHueco.appUser.friends.values.filter {
            $0.isNearby
        }
    }

    /**
     Returns all friends that are currently available.
     - returns: Friends with their current free time periods
     */
    func currentlyAvailableFriends() -> [(friend:User, freeTime:Event)] {

        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()

        for friend in enHueco.appUser.friends.values {
            if let freeTime = friend.currentFreeTimePeriod() {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }

        return friendsAndFreeTimePeriods
    }

    /**
     Returns all friends that will soon be available.
     - returns: Friends with their current free time period
     */
    func soonAvailableFriendsWithinTimeInterval(interval: NSTimeInterval) -> [(friend:User, freeTime:Event)] {

        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()

        let currentDate = NSDate()

        for friend in enHueco.appUser.friends.values {
            if let freeTime = friend.nextFreeTimePeriod() where freeTime.startHourInNearestPossibleWeekToDate(currentDate).timeIntervalSinceNow <= interval {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }

        return friendsAndFreeTimePeriods
    }

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
                "valid_until": newFreeTimePeriod.endHourInNearestPossibleWeekToDate(NSDate()).serverFormattedString(),
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