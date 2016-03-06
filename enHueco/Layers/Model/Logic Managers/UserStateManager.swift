//
//  FreeTimePeriodsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

class UserStateManager
{
    private static let instance = UserStateManager()

    private init() {}
    
    class func sharedManager() -> UserStateManager
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
    func postInstantFreeTimePeriod(newFreeTimePeriod: Event?, completionHandler: (succeeded: Bool)->Void )
    {
        //TODO: Send to server
        
        //Temporary
        enHueco.appUser.schedule.instantFreeTimePeriod = newFreeTimePeriod
        
        dispatch_async(dispatch_get_main_queue())
            {
                completionHandler(succeeded: true)
                
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: enHueco, userInfo: nil)
        }
    }
}