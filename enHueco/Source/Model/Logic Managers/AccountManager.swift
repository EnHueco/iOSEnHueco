//
//  AccountManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

/// Handles account related operations (i.e. Signup, Login, Logout, Forgot Password, etc)
class AccountManager {

    private init() {}

    static let sharedManager = AccountManager()
    
    /// The ID of the currently logged in user
    var userID: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }
    
    func loginWith(facebookToken facebookToken: String, completionHandler: BasicCompletionHandler) {
        
        FIRAuth.auth()?.signInWithCredential(FIRFacebookAuthProvider.credentialWithAccessToken(facebookToken)) { (user, error) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    /// Creates an account.
    func loginWith(email email: String, password: String, completionHandler: BasicCompletionHandler) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }

    /// Creates an account.
    func signupWith(email email: String, password: String, completionHandler: BasicCompletionHandler) {

        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }

    func logOut() throws {
        try FIRAuth.auth()?.signOut()
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
    }
}