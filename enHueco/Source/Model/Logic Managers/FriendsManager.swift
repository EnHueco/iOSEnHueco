//
//  RequestsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

class FriendsManager: FirebaseLogicManager {

    private init() {}

    static let sharedManager = FriendsManager()

    /// Deletes a friend.
    func deleteFriend(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }

        let update = [
            appUser.uid + "/" + friendID : NSNull(),
            friendID + "/" + appUserID : NSNull()
        ]
        
        FIRDatabase.database().reference().child(FirebasePaths.friends).updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }

    /// Sends a friend request to the username provided and notifies the result via Notification Center.
    func sendFriendRequestTo(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }
        
        let update = [
            FirebasePaths.sentRequests + "/" + appUserID : friendID,
            FirebasePaths.receivedRequests + "/" + friendID : appUserID
        ]
        
        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    /// Accepts friend request from the friend id provided.
    func acceptFriendRequestFrom(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler) else { return }

        let update = [
            FirebasePaths.receivedRequests + "/" + appUserID + "/" + friendID : NSNull(),
            FirebasePaths.sentRequests + "/" + friendID + "/" + appUserID  : NSNull(),
            FirebasePaths.friends + "/" + appUser.uid : friendID,
            FirebasePaths.friends + "/" + friendID : appUserID
        ]

        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    /**
     Performs a search for users based on their name
     
     - parameter searchText:        Text to search
     */
    func searchUsersWith(searchText searchText: String, institutionID: String, completionHandler: (results:[User]) -> ()) {
        
        guard !searchText.isBlank() else {
            dispatch_async(dispatch_get_main_queue()) { completionHandler(results: [User]()) }
            return
        }
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(institutionID).observeSingleEventOfType(.Value) { (snapshot) in
            
            guard let value = snapshot.value as? [[String : AnyObject]] else {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(results: [User]()) }
                return
            }
            
            let filteredFriendsJSON = value.filter {
                
                let firstNames = ($0[User.JSONKeys.firstNames] as? String) ?? ""
                let lastNames = ($0[User.JSONKeys.lastNames] as? String) ?? ""
                
                for word in [firstNames.componentsSeparatedByString(" "), lastNames.componentsSeparatedByString(" ")] where word.lowercaseString.hasPrefix(searchText.lowercaseString) {
                    return true
                }
                
                return false
            }

            completionHandler(results: try? [User](js: filteredFriendsJSON) ?? [])
        }
    }
}