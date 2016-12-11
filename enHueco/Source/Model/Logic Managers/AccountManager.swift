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
import SwiftyJSON

struct SignupInfo {

    var firstNames: String
    var lastNames: String
    var phoneNumber: String?
    var gender: Gender
    var imageURL: URL?
}

/// Handles account related operations (i.e. Signup, Login, Logout, Forgot Password, etc)
class AccountManager {

    fileprivate init() {}

    static let shared = AccountManager()
    
    /// The ID of the currently logged in user
    var userID: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }
    
    func loginWith(_ facebookToken: String, completionHandler: @escaping BasicCompletionHandler) {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email, gender"]).start() { (_, userDictionary, error) -> Void in
            
            guard error == nil else {
                DispatchQueue.main.async { completionHandler(error) }
                return
            }
         
            FIRAuth.auth()?.signIn(with: FIRFacebookAuthProvider.credential(withAccessToken: facebookToken)) { (user, error) in
                
                guard let user = user, error == nil else {
                    DispatchQueue.main.async { completionHandler(error) }
                    return
                }
                
                let userJSON = JSON(userDictionary ?? [:])
                
                guard let firstNames = userJSON["first_name"].string,
                    let lastName = userJSON["last_name"].string,
                    let gender: Gender = userJSON["gender"].string == "female" ? .Female : .Male else {
                        DispatchQueue.main.async { completionHandler(GenericError.unknownError) }
                        return
                }
                
                self.checkIfUserExists(id: user.uid) { (exists, error) in
                    
                    guard error == nil else {
                        completionHandler(error)
                        return
                    }

                    if exists == true {
                        completionHandler(nil)
                        return
                        
                    } else {
                        
                        self.fetchImageFromFacebook { (imageURL, error) in
                            let info = SignupInfo(firstNames: firstNames, lastNames: lastName, phoneNumber: nil, gender: gender, imageURL: imageURL)
                            
                            self.createUser(id: user.uid, userInfo: info) { (error) in
                                completionHandler(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfUserExists(id: String, completionHandler: @escaping (_ exists: Bool?, _ error: Error?) -> Void) {
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            DispatchQueue.main.async {
                completionHandler(snapshot.exists(), nil)
            }
            
        }) { (error) in
            
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
        }
    }
    
    fileprivate func createUser(id: String, userInfo: SignupInfo, completionHandler: @escaping BasicCompletionHandler) {
        
        let user = User(id: id, institution: nil, firstNames: userInfo.firstNames, lastNames: userInfo.lastNames, image: userInfo.imageURL, gender: userInfo.gender)
        
        guard let updateJSON = (try? user.foundationDictionary()) ?? nil else {
            assertionFailure()
            DispatchQueue.main.async{ completionHandler(GenericError.unknownError) }
            return
        }
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(id).updateChildValues(updateJSON) { (error, reference) in
            
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
    }
    
    func fetchImageFromFacebook(completionHandler: @escaping (_ imageURL: URL?, _ error: Error?) -> Void) {
        
        FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields": "url", "width": "500", "redirect": "false"], httpMethod: "GET").start() {(_, result, error) -> Void in
            
            let json = JSON(result ?? [:])
            
            guard let imageURLString = json["data"]["url"].string,
                let imageURL = URL(string: imageURLString)
                else {
                    completionHandler(nil, error)
                    return
            }
            
            completionHandler(imageURL, nil)
        }
    }

    func logOut() throws {
        try FIRAuth.auth()?.signOut()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}
