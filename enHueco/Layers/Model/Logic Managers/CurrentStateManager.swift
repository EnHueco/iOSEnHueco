//
//  FreeTimePeriodsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

class CurrentStateManager
{
    private static let instance = CurrentStateManager()

    private init() {}
    
    class func sharedManager() -> CurrentStateManager
    {
        return instance
    }

    /**
     Returns all friends that are currently available and nearby.
     - returns: Friend with their current free time period
     */
    func currentlyAvailableAndNearbyFriends() -> [(friend: User, freeTime: Event)]
    {
        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
        
        for friend in enHueco.appUser.friends.values
        {
            if let freeTime = friend.currentFreeTimePeriod() where friend.isNearby
            {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }
        
        return friendsAndFreeTimePeriods
    }
    
    func friendsCurrentlyNearby() -> [User]
    {
        return enHueco.appUser.friends.values.filter { $0.isNearby }
    }
    
    /**
     Returns all friends that are currently available.
     - returns: Friends with their current free time periods
     */
    func currentlyAvailableFriends() -> [(friend: User, freeTime: Event)]
    {
        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
        
        for friend in enHueco.appUser.friends.values
        {
            if let freeTime = friend.currentFreeTimePeriod()
            {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }
        
        return friendsAndFreeTimePeriods
    }
    
    /**
     Returns all friends that will soon be available.
     - returns: Friends with their current free time period
     */
    func soonAvailableFriendsWithinTimeInterval(interval: NSTimeInterval) -> [(friend: User, freeTime: Event)]
    {
        var friendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
        
        let currentDate = NSDate()
        
        for friend in enHueco.appUser.friends.values
        {
            if let freeTime = friend.nextFreeTimePeriod() where freeTime.startHourInDate(currentDate).timeIntervalSinceNow <= interval
            {
                friendsAndFreeTimePeriods.append((friend, freeTime))
            }
        }
        
        return friendsAndFreeTimePeriods
    }
    
    /**
     Posts an instant free time period that everyone sees and that overrides any classes present in the app user's schedule during the instant free time period duration.
     Network operation must succeed immediately or else the newFreeTimePeriod is discarded
     */
    func postInstantFreeTimePeriod(newFreeTimePeriod: Event, completionHandler: (success: Bool, error: ErrorType?) -> Void )
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "GET"
        
        var instantEvent : [String : AnyObject] =
        [
            "type" : "EVENT",
            "valid_type" : newFreeTimePeriod.endHourInDate(NSDate()),
        ]
        
        instantEvent["name"] = newFreeTimePeriod.name
        instantEvent["location"] = newFreeTimePeriod.location
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: ["immediate_event" : instantEvent], onSuccess: { (JSONResponse) -> () in
            
            enHueco.appUser.schedule.instantFreeTimePeriod = newFreeTimePeriod
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, onFailure: {(compoundError) -> () in
        
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }
    
    func deleteInstantFreeTimePeriodWithCompletionHandler(completionHandler: (success: Bool, error: ErrorType?) -> Void)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.FriendsSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: ["immediate_event" : ""], onSuccess: { (JSONResponse) -> () in
                        
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
            }, onFailure: {(compoundError) -> () in
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: false, error: compoundError.error)
                }
        })
    }
}