//
//  System.swift
//  enHueco
//
//  Created by Diego Montoya on 7/15/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

let system = System()

enum EHSystemNotification: String
{
    case SystemDidLogin = "SystemDidLogin", SystemCouldNotLoginWithError = "SystemCouldNotLoginWithError"
    case SystemDidReceiveFriendAndScheduleUpdates = "SystemDidReceiveFriendAndScheduleUpdates"
    case SystemDidAddFriend = "SystemDidAddFriend"
}

class System
{
    var appUser: AppUser!
    
    private init()
    {
        //Pruebas
        
        appUser = AppUser(username: "pa.perez10", token: "adfsdf", lastUpdatedOn: "", firstNames: "Pepito Alberto", lastNames: "Perez Uribe", phoneNumber: 94189, imageURL: "")
        let friend = User(username: "amiguito123", firstNames: "Diego", lastNames: "Montoya Sefair", phoneNumber: 1234567, imageURL: nil)
        let start = NSDateComponents(); start.hour = 0; start.minute = 00
        let end = NSDateComponents(); end.hour = 1; end.minute = 00
        let gap = Gap(startHour: start, endHour: end)
        friend.schedule.weekDays[6].gaps.append(gap)
        appUser.friends.append(friend)
        
        //////////
    }
    
    /**
        Checks for updates on the server including Session Status, Friend list, Friends Schedule, Users Info
    */
    func checkForUpdates ()
    {
        
    }
    
    /*
        Logs user in for the first time or when session expires. Creates or replaces the AppUser.
    */
    func login (username: String, password: String)
    {
        let params = ["user_id":username, "password":password]
        let URL = NSURL(string: APIURLS.URLS.base.rawValue + APIURLS.URLS.authSegment.rawValue)!
        
        HTTPRequestResponseManager.sendAsyncRequestToURL(URL, usingMethod: .POST, withJSONParams: params, onSuccess: { (response) -> () in
            
            guard let token = response["value"] as? String else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemCouldNotLoginWithError.rawValue, object: self, userInfo: ["error": "Response received but token missing"])
                return
            }
            
            let user = response["user"] as! Dictionary<String, String>
            let username = user["login"] as String!
            let firstNames = user["firstNames"] as String!
            let lastNames = user["lastNames"] as String!
            let imageURL = user["imageURL"] as String!
            let lastUpdatedOn = user["lastUpdated_on"] as String!
            
            let appUser = AppUser(username: username, token: token, lastUpdatedOn: lastUpdatedOn, firstNames: firstNames, lastNames: lastNames, phoneNumber: nil, imageURL: imageURL)
            
            self.appUser = appUser
            
            self.updateFriendsAndFriendsSchedules()
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidLogin.rawValue, object: self, userInfo: nil)
            
        }) { (error) -> () in
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemCouldNotLoginWithError.rawValue, object: self, userInfo: ["error": error as! AnyObject])
        }
    }
    
    func updateFriendsAndFriendsSchedules ()
    {
        appUser.updateFriendsAndFriendsSchedules()
    }
}