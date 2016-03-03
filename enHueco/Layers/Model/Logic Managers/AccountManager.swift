//
//  AccountManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

class AccountManager
{
    private init() {}
    
    /// Logs user in for the first time or when session expires. Creates or replaces the AppUser (enhueco.appUser)
    class func loginWithUsername (username: String, password: String, completionHandler: (success: Bool, error: ErrorType?) -> Void)
    {
        let params = ["user_id":username, "password":password]
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.AuthSegment)!)
        request.HTTPMethod = "POST"
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, onSuccess: { (response) -> () in
            
            enHueco.appUser = AppUser(JSONDictionary: response as! [String : AnyObject])
            
            AppUserInformationManager.downloadProfilePicture()
            AppUserInformationManager.fetchUpdatesForAppUserAndSchedule()
            FriendsManager.fetchUpdatesForFriendsAndFriendSchedules()
            
            try! PersistenceManager.persistData()
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, onFailure: { (error) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error.error)
            }
        })
    }
    
    class func logOut()
    {
        // TODO: Delete persistence information, send logout notification to server so token is deleted.
        
        do
        {
            enHueco.appUser = nil
            ImagePersistenceManager.deleteImage(ImagePersistenceManager.fileInDocumentsDirectory("profile.jpg"))
            try PersistenceManager.deleteAllPersistenceData()
        }
        catch
        {
            
        }
    }
}