//
//  AccountManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

/// Handles account related operations (i.e. Signup, Login, Logout, Forgot Password, etc)

class AccountManager {
    static let sharedManager = AccountManager()

    private init() {}

    /// Logs user in for the first time or when session expires. Creates or replaces the AppUser (enhueco.appUser)
    class func loginWithUsername(username: String, password: String, completionHandler: BasicCompletionHandler) {

        let params = ["user_id": username, "password": password]

        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.AuthSegment)!)
        request.HTTPMethod = "POST"

        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, successCompletionHandler: {
            (response) -> () in

            guard let token = response["value"] as? String else
            {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: false, error: nil)
                }
                return
            }

            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")

            enHueco.appUser = AppUser(JSONDictionary: response["user"] as! [String:AnyObject])

            let _ = try? PersistenceManager.sharedManager.persistData()

            AppUserInformationManager.sharedManager.fetchUpdatesForAppUserAndScheduleWithCompletionHandler(nil)
            AppUserInformationManager.sharedManager.downloadProfilePictureWithCompletionHandler(nil)
            FriendsManager.sharedManager.fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler(nil)

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }, failureCompletionHandler: {
            (error) -> () in

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: error.error)
            }
        })
    }

    func logOut() {

        enHueco.appUser = nil
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        PersistenceManager.sharedManager.deleteAllPersistenceData()
    }
}