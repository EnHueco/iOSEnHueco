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
import FBSDKCoreKit
import Genome
import PureJsonSerializer

private struct SignupInfo {
    
    var firstNames: String
    var lastNames: String
    var phoneNumber: String?
    var gender: Gender
    
    func updateIntent() -> UserUpdateIntent {
        return UserUpdateIntent(institution: nil, firstNames: firstNames, lastNames: lastNames, image: nil, imageThumbnail: nil, phoneNumber: phoneNumber, gender: gender)
    }
}

/// Handles account related operations (i.e. Signup, Login, Logout, Forgot Password, etc)
class AccountManager {

    private init() {}

    static let sharedManager = AccountManager()
    
    /// The ID of the currently logged in user
    var userID: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }
    
    func loginWith(facebookToken facebookToken: String, completionHandler: BasicCompletionHandler) {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email, gender"]).startWithCompletionHandler() { (_, userDictionary, error) -> Void in
            
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(error: error) }
                return
            }
         
            FIRAuth.auth()?.signInWithCredential(FIRFacebookAuthProvider.credentialWithAccessToken(facebookToken)) { (user, error) in
                
                guard let user = user where error == nil else {
                    dispatch_async(dispatch_get_main_queue()) { completionHandler(error: error) }
                    return
                }
                
                guard let firstNames = userDictionary["first_name"] as? String,
                    let lastName = userDictionary["last_name"] as? String,
                    let gender: Gender = (userDictionary["gender"] as? String) == "female" ? .Female : .Male else {
                        dispatch_async(dispatch_get_main_queue()) { completionHandler(error: GenericError.UnknownError) }
                        return
                }
                
                self.checkIfUserExists(ID: user.uid) { (exists, error) in
                    
                    guard error == nil else {
                        completionHandler(error: error)
                        return
                    }

                    if exists == true {
                        completionHandler(error: nil)
                        return
                        
                    } else {
                        let info = SignupInfo(firstNames: firstNames, lastNames: lastName, phoneNumber: nil, gender: gender)
                        self.createUser(ID: user.uid, userInfo: info) { (error) in
                            completionHandler(error: error)
                        }
                    }
                }
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
    
    private func checkIfUserExists(ID ID: String, completionHandler: (exists: Bool?, error: ErrorType?) -> Void) {
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(ID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(exists: snapshot.exists(), error: nil)
            }
            
        }) { (error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(exists: nil, error: error)
            }
        }
    }
    
    private func createUser(ID ID: String, userInfo: SignupInfo, completionHandler: BasicCompletionHandler) {
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(ID).child(User.JSONKeys.id).setValue(ID) { (error, _) in
            
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(error: error) }
                return
            }
            
            AppUserManager.sharedManager.updateUserWith(userInfo.updateIntent(), completionHandler: completionHandler)
        }
    }

    func logOut() throws {
        try FIRAuth.auth()?.signOut()
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
    }
}