//
//  AppUser.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class UserStringEncodingCharacters
{
    static let splitCharacter = "\\"
    static let separationCharacter = "-"
    static let multipleElementsCharacter = ","
    static let hourMinuteSeparationCharacter = ":"
}

/// The user that uses the app.
class AppUser: User
{
    /// Session token
    var token : String
    
    ///Dictionary containing the AppUser's friends with their usernames as their keys
    var friends = [String : User]()
    
    var outgoingFriendRequests = [User]()
    var incomingFriendRequests = [User]()
        
    init(username: String, token : String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?, ID: String, lastUpdatedOn: NSDate)
    {
        self.token = token
        
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    convenience init(JSONDictionary: [String : AnyObject])
    {
        let token = JSONDictionary["value"] as? String
        let user = User(JSONDictionary: JSONDictionary["user"] as! [String : AnyObject])
        
        self.init(username: user.username, token: token ?? enHueco.appUser.token, firstNames: user.firstNames, lastNames: user.lastNames, phoneNumber: nil, imageURL: user.imageURL, ID: user.ID!, lastUpdatedOn: user.lastUpdatedOn)
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let token = decoder.decodeObjectForKey("token") as? String,
            let friends = decoder.decodeObjectForKey("friends") as? [String : User],
            let incomingFriendRequests = decoder.decodeObjectForKey("incomingFriendRequests") as? [User],
            let outgoingFriendRequests = decoder.decodeObjectForKey("outgoingFriendRequests") as? [User]
            else
        {
            self.token = ""
            self.friends = [String : User]()
            self.incomingFriendRequests = [User]()
            self.outgoingFriendRequests = [User]()
            super.init(coder: decoder)
            
            return nil
        }
        
        self.token = token
        self.friends = friends
        self.incomingFriendRequests = incomingFriendRequests
        self.outgoingFriendRequests = outgoingFriendRequests
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(token, forKey: "token")
        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(incomingFriendRequests, forKey: "incomingFriendRequests")
        coder.encodeObject(outgoingFriendRequests, forKey: "outgoingFriendRequests")
    }
    
    // MARK: Updates
    
    func fetchUpdatesForFriendLocations (successHandler: () -> (), failureHandler: () -> ())
    {
        
    }
    
    // MARK: Functions
        
    /// When currentBSSID is set, refreshes the isNearby property for all friends.
    override func refreshIsNearby()
    {
        for friend in friends.values
        {
            friend.refreshIsNearby()
        }
    }
        
    /*

    Returns the string encoded representation of the user, to be decoded by "addFriendFromStringEncodedFriendRepresentation:"
    Formatted as follows:
    username/first names, last names/phone number/imageURL/00:00-00:10,00:30-01:30/00:00-00:10,00:30-01:30
    */
    func stringEncodedUserRepresentation () -> String
    {
        typealias Characters = UserStringEncodingCharacters
        
        var encodedSchedule = ""

        // Add username
        encodedSchedule += username + Characters.splitCharacter
        
        // Add names
        encodedSchedule += firstNames + Characters.separationCharacter + lastNames + Characters.splitCharacter
        
        // Add phone
        encodedSchedule += String(phoneNumber) + Characters.splitCharacter
        
        // Add image
        encodedSchedule += (imageURL?.absoluteString)! + Characters.splitCharacter
        
        var firstEvent = true;
        
        // Add events
        for (i, daySchedule) in schedule.weekDays.enumerate() where i > 0
        {
            for (j, event) in daySchedule.events.enumerate()
            {
                if firstEvent
                {
                    firstEvent = false
                }
                else
                {
                    encodedSchedule += Characters.multipleElementsCharacter
                }
                
                let eventType = event.type == EventType.FreeTime ? "G" : "C"
                
                // Add event type
                encodedSchedule += eventType + Characters.separationCharacter
                
                // Add event weekday
                encodedSchedule += String(i) + Characters.separationCharacter
                
                // Add hours
                encodedSchedule += "\(event.startHour.hour)\(Characters.hourMinuteSeparationCharacter)\(event.startHour.minute)"
                encodedSchedule += Characters.separationCharacter
                encodedSchedule += "\(event.endHour.hour)\(Characters.hourMinuteSeparationCharacter)\(event.endHour.minute)"
            }
        }
        
        encodedSchedule += Characters.splitCharacter
        
        return encodedSchedule
    }
}

