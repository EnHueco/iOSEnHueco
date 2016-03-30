//
//  AccountManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

/// Handles account related operations (i.e. Signup, Login, Logout, Forgot Password, etc)
class AccountManager
{
    static let sharedManager = AccountManager()
    
    private init() {}
        
    /// Logs user in for the first time or when session expires. Creates or replaces the AppUser (enhueco.appUser)
    class func loginWithUsername (username: String, password: String, completionHandler: BasicCompletionHandler)
    {
        let params = ["user_id":username, "password":password]
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.AuthSegment)!)
        request.HTTPMethod = "POST"
                
        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, successCompletionHandler: { (response) -> () in
            
            enHueco.appUser = AppUser(JSONDictionary: response as! [String : AnyObject])
            
            AppUserInformationManager.sharedManager.downloadProfilePictureWithCompletionHandler(nil)
            AppUserInformationManager.sharedManager.fetchUpdatesForAppUserAndScheduleWithCompletionHandler(nil)
            FriendsManager.sharedManager.fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(nil)
            
            try? PersistenceManager.sharedManager.persistData()
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, failureCompletionHandler: { (error) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error.error)
            }
        })
    }
    
    func logOut()
    {
        // TODO: Delete persistence information, send logout notification to server so token is deleted.
        
        enHueco.appUser = nil
        try? PersistenceManager.sharedManager.deleteAllPersistenceData()
    }
}