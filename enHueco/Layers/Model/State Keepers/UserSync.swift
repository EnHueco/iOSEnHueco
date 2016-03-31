//
//  UserSync.swift
//  enHueco
//
//  Created by Diego Gómez on 3/31/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

class UserSync: NSObject
{
    let username : String
    let lastUpdatedOn : NSDate
    let scheduleLastUpdatedOn : NSDate
    let immediateEventLastUpdatedOn : NSDate
    
    init(JSONDictionary: [String : AnyObject])
    {
        self.username = JSONDictionary["login"] as! String
        self.lastUpdatedOn = NSDate(serverFormattedString:
            JSONDictionary["updated_on"] as! String)!
        self.scheduleLastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["schedule_updated_on"] as! String)!
        self.immediateEventLastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["immediate_event_updated_on"] as! String)!
    }
    
    init(fromUser: User)
    {
        self.username = fromUser.username
        self.lastUpdatedOn = fromUser.lastUpdatedOn
        self.scheduleLastUpdatedOn = fromUser.lastUpdatedOn //fromUser.schedule.lastUpdatedOn
        self.immediateEventLastUpdatedOn = fromUser.lastUpdatedOn //fromUser.immediateEvent.lastUpdatedOn
    }
    
    func toJSONDictionary() -> [String : AnyObject]
    {
        return ["login" : self.username]
    }
}
