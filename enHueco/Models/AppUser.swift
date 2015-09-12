//
//  AppUser.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class AppUser: User
{
    var token : String
    var lastUpdatedOn: String

    var friends = [User]()
    
    var friendRequests = [String]()
    
    init(username: String, token : String, lastUpdatedOn: String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?)
    {
        self.token = token
        self.lastUpdatedOn = lastUpdatedOn
        
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL)
    }
    
    func updateFriendsAndFriendsSchedules ()
    {
        let params = []
        let URL = NSURL(string: APIURLS.URLS.base.rawValue)!
        
        HTTPRequestResponseManager.sendAsyncRequestToURL(URL, usingMethod: .POST, withJSONParams: nil, onSuccess: { (response) -> () in
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates.rawValue, object: self, userInfo: nil)
            
        }) { (error) -> () in
                
                
        }
    }
    
    func sendFriendRequest ()
    {
        
    }
    
    func sendFriendRequestToUserWithUsername (username: String)
    {
        
    }
    
    /**
        Adds friend from their string encoded representation.
        The AppUser user is also added as a friend of the friend they are adding, without any approvals from either side.
    */
    func addFriendFromStringEncodedFriendRepresentation (encodedFriend: String) throws
    {
        let mainComponents = encodedFriend.componentsSeparatedByString("/")
        
        let username = mainComponents[0]
        
        let fullNameComponents = mainComponents[1].componentsSeparatedByString(",")
        let firstNames = fullNameComponents[0]
        let lastNames = fullNameComponents[1]
        
        let phoneNumber = mainComponents[2]
        
        let friend = User(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: nil)

        let encodedWeekDays = mainComponents[4].componentsSeparatedByString("|")
        
        for (i, encodedWeekDay) in encodedWeekDays.enumerate()
        {
            var gaps = [Gap]()
            var classes = [Class]()

            let encodedWeekDayComponents = encodedWeekDay.componentsSeparatedByString("#")
            let encodedGaps = encodedWeekDayComponents[0].componentsSeparatedByString(",")
            
            if encodedWeekDayComponents[0] != ""
            {
                for encodedGap in encodedGaps
                {
                    let hoursComponents = encodedGap.componentsSeparatedByString("-")
                    
                    let startHourComponents = hoursComponents[0].componentsSeparatedByString(":")
                    let startHourDateComponents = NSDateComponents()
                    startHourDateComponents.hour = Int(startHourComponents[0])!
                    startHourDateComponents.minute = Int(startHourComponents[1])!
                    
                    let endHourComponents = hoursComponents[1].componentsSeparatedByString(":")
                    let endHourDateComponents = NSDateComponents()
                    endHourDateComponents.hour = Int(endHourComponents[0])!
                    endHourDateComponents.minute = Int(endHourComponents[1])!
                    
                    gaps.append(Gap(daySchedule: schedule.weekDays[i], startHour: startHourDateComponents, endHour: endHourDateComponents))
                }
            }
            
            if encodedWeekDayComponents[1] != ""
            {
                let encodedClasses = encodedWeekDayComponents[1].componentsSeparatedByString(",")
                
                for encodedClass in encodedClasses
                {
                    let classComponents = encodedClass.componentsSeparatedByString("-")
                    
                    let startHourComponents = classComponents[0].componentsSeparatedByString(":")
                    let startHourDateComponents = NSDateComponents()
                    startHourDateComponents.hour = Int(startHourComponents[0])!
                    startHourDateComponents.minute = Int(startHourComponents[1])!
                    
                    let endHourComponents = classComponents[1].componentsSeparatedByString(":")
                    let endHourDateComponents = NSDateComponents()
                    endHourDateComponents.hour = Int(endHourComponents[0])!
                    endHourDateComponents.minute = Int(endHourComponents[1])!
                    
                    let location = classComponents[2]
                    
                    classes.append(Class(startHour: startHourDateComponents, endHour: endHourDateComponents, location: (location != "" ? location:nil) ))
                }
            }
            
            friend.schedule.weekDays[i].gaps = gaps
            friend.schedule.weekDays[i].classes = classes
        }
        
        friends.append(friend)
        
        NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidAddFriend.rawValue, object: system, userInfo: nil)
    }
    
    /**
        Adds the AppUser as a friend of the friend they just added by string encoded representation (QR)
        App user is added as a friend on the server directly (without friends confirmation)
        Must only be called from "addFriendFromStringEncodedFriendRepresentation:".
    */
    private func _addAppUserAsFriendOfStringEncodedAddedFriend ()
    {
        // TODO
    }
    
    /**
        Resturns the string encoded representation of the user, to be decoded by "addFriendFromStringEncodedFriendRepresentation:"
        Formatted as follows:
        username/first names, last names/phone number/imageURL/00:00-00:10,00:30-01:30/00:00-00:10,00:30-01:30
    */
    func stringEncodedUserRepresentation () -> String
    {
        var encodedSchedule = username
        encodedSchedule += "/" + firstNames + "," + lastNames
        encodedSchedule += "/" + String(phoneNumber)
        encodedSchedule += "/ /"
        
        for (i, daySchedule) in schedule.weekDays.enumerate()
        {
            for (j, gap) in daySchedule.gaps.enumerate()
            {
                encodedSchedule += "\(gap.startHour.hour):\(gap.startHour.minute)"
                encodedSchedule += "-"
                encodedSchedule += "\(gap.startHour.hour):\(gap.startHour.minute)"

                if j != daySchedule.gaps.count-1 { encodedSchedule += "," }
            }
            
            encodedSchedule += "#"
            
            for (j, aClass) in daySchedule.classes.enumerate()
            {
                encodedSchedule += "\(aClass.startHour.hour):\(aClass.startHour.minute)"
                encodedSchedule += "-"
                encodedSchedule += "\(aClass.startHour.hour):\(aClass.startHour.minute)"
                if aClass.location != nil { encodedSchedule += "-"+aClass.location! }
                
                if j != daySchedule.classes.count-1 { encodedSchedule += "," }
            }
            
            if i != schedule.weekDays.count-1 { encodedSchedule += "|" }
        }
        
        return encodedSchedule
    }
    
    func importScheduleFromCalendar()
    {
        
    }
    
    //NSCoding 
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let token = decoder.decodeObjectForKey("token") as? String,
            let lastUpdatedOn = decoder.decodeObjectForKey("lastUpdatedOn") as? String,
            let friends = decoder.decodeObjectForKey("friends") as? [User],
            let friendRequests = decoder.decodeObjectForKey("friendRequests") as? [String]
        else
        {
            self.token = ""
            self.lastUpdatedOn = ""
            self.friends = [User]()
            self.friendRequests = [String]()
            super.init(coder: decoder)
            
            return nil
        }
        
        self.token = token
        self.lastUpdatedOn = lastUpdatedOn
        self.friends = friends
        self.friendRequests = friendRequests
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(token, forKey: "token")
        coder.encodeObject(lastUpdatedOn, forKey: "lastUpdatedOn")
        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(friendRequests, forKey: "friendRequests")
    }
}

