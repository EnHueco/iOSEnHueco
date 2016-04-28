//
//  AppUser.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

/// The user that uses the app.
class AppUser: User
{
    ///Dictionary containing the AppUser's friends with their usernames as their keys
    var friends = [String : User]()
    
    var outgoingFriendRequests = [User]()
    var incomingFriendRequests = [User]()
        
    override init(username: String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?, imageThumbnailURL: NSURL?, ID: String, lastUpdatedOn: NSDate)
    {
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, imageThumbnailURL: imageThumbnailURL, ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    override init(JSONDictionary: [String : AnyObject])
    {
        super.init(JSONDictionary: JSONDictionary)
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let friends = decoder.decodeObjectForKey("friends") as? [String : User],
            let incomingFriendRequests = decoder.decodeObjectForKey("incomingFriendRequests") as? [User],
            let outgoingFriendRequests = decoder.decodeObjectForKey("outgoingFriendRequests") as? [User]
            else
        {
            return nil
        }
        
        self.friends = friends
        self.incomingFriendRequests = incomingFriendRequests
        self.outgoingFriendRequests = outgoingFriendRequests
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(incomingFriendRequests, forKey: "incomingFriendRequests")
        coder.encodeObject(outgoingFriendRequests, forKey: "outgoingFriendRequests")
    }
    
    // MARK: Updates
    
    func fetchUpdatesForFriendLocations (successHandler: () -> (), failureHandler: () -> ())
    {
        
    }
            
    /// When currentBSSID is set, refreshes the isNearby property for all friends.
    override func refreshIsNearby()
    {
        for friend in friends.values
        {
            friend.refreshIsNearby()
        }
    }
        
    override func updateUserWithJSONDictionary(JSONDictionary: [String : AnyObject])
    {
        super.updateUserWithJSONDictionary(JSONDictionary)
                
        PrivacyManager.sharedManager.changeUserDefaultsValueForPrivacySetting(.ShowEventLocations, toNewValue: JSONDictionary[PrivacySetting.ShowEventLocations.rawValue] as! Bool)
        PrivacyManager.sharedManager.changeUserDefaultsValueForPrivacySetting(.ShowEventNames, toNewValue: JSONDictionary[PrivacySetting.ShowEventNames.rawValue] as! Bool)
    }
}

