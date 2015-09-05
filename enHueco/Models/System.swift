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
}

class System
{
    var appUser: AppUser!
    
    private init()
    {
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
        
        HTTPRequestResponseManager.sendAsyncRequestToURL(URL, usingMethod: HTTPMethod.POST, withJSONParams: params, onSuccess: { (response) -> () in
            
            guard let token = response["value"] as? String else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemCouldNotLoginWithError.rawValue, object: self, userInfo: ["error": "Response received but token missing"])
                return
            }
            
            let username = response["username"] as! String
            let firstNames = response["firstNames"] as! String
            let lastNames = response["lastNames"] as! String
            let imageURL = response["imageURL"] as! String
            let lastUpdatedOn = response["lastUpdatedOn"] as! String
            
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