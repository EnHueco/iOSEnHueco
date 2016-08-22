//
//  AccountManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

/// Handles account related operations (i.e. Signup, Login, Logout, Forgot Password, etc)
class AccountManager {
    private init() {}
    
    class func loginWith(facebookToken facebookToken: String, completionHandler: BasicCompletionHandler) {
        
        FIRAuth.auth()?.signInWithCredential(facebookToken) { (user, error) in
            dispatch_async(dispatch_get_main_queue()){
                completion
            }
        }
    }
    
    /// Creates an account.
    class func loginWith(email email: String, password: String, completionHandler: BasicCompletionHandler) {
        
        FIRAuth.auth()?.createUserWithEmail(username, password: password) { (user, error) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }

    /// Creates an account.
    class func signupWith(email email: String, password: String, completionHandler: BasicCompletionHandler) {

        FIRAuth.auth()?.createUserWithEmail(username, password: password) { (user, error) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }

    class func logOut() throws {
        try FIRAuth.auth()?.signOut()
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
    }
}