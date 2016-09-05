//
//  RequestsManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome
import Firebase

class FriendsManager: FirebaseLogicManager {

    private init() {}

    static let sharedManager = FriendsManager()

    /// Deletes a friend.
    func deleteFriend(id friendID: String, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler)?.uid else { return }

        let update = [
            appUserID + "/" + friendID : NSNull(),
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
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler)?.uid else { return }
        
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
        
        guard let appUserID = firebaseUser(errorHandler: completionHandler)?.uid else { return }

        let update = [
            FirebasePaths.receivedRequests + "/" + appUserID + "/" + friendID : NSNull(),
            FirebasePaths.sentRequests + "/" + friendID + "/" + appUserID  : NSNull(),
            FirebasePaths.friends + "/" + appUserID : friendID,
            FirebasePaths.friends + "/" + friendID : appUserID
        ]

        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    func fetchUserWithID(id: String, completionHandler: (user: User?, error: ErrorType?) -> Void) {
        
        fetchUsersWithIDs([id]) { (users, error) in
            completionHandler(user: users?.first, error: error)
        }
    }
    
    func fetchUsersWithIDs(ids: [String], completionHandler: (users: [User]?, error: ErrorType?) -> Void) {
                
        var errorOccurred = false
        var users = [User]()
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        for id in ids {
            
            FIRDatabase.database().reference().child(FirebasePaths.users).child(id).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                dispatch_async(queue) {
                    guard !errorOccurred else { return }
                    
                    guard let valueJSON = snapshot.value as? [String : AnyObject], let user = try? User(js: valueJSON) else {
                        dispatch_async(dispatch_get_main_queue()){
                            errorOccurred = true
                            completionHandler(users: nil, error: GenericError.UnknownError)
                        }
                        return
                    }
                    
                    users.append(user)
                    
                    if users.count == ids.count {
                        dispatch_async(dispatch_get_main_queue()) {
                            completionHandler(users: users, error: nil)
                        }
                    }
                }
                
            }, withCancelBlock: { (error) in
                
                dispatch_async(queue) {
                    guard !errorOccurred else { return }

                    errorOccurred = true
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(users: nil, error: error)
                    }
                }
            })
        }
    }
    
    /**
     Performs a search for users based on their name
     
     - parameter searchText:        Text to search
     */
    func searchUsersByName(searchText searchText: String, institutionID: String?, completionHandler: (results:[User]) -> ()) {
        
        guard !searchText.isBlank() else {
            dispatch_async(dispatch_get_main_queue()) { completionHandler(results: [User]()) }
            return
        }
        
        FIRDatabase.database().reference().child(FirebasePaths.users).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            guard let value = snapshot.value as? [[String : AnyObject]] else {
                dispatch_async(dispatch_get_main_queue()) { completionHandler(results: [User]()) }
                return
            }
            
            let filteredFriendsJSON = value.filter {
                
                let firstNames = ($0[User.JSONKeys.firstNames] as? String) ?? ""
                let lastNames = ($0[User.JSONKeys.lastNames] as? String) ?? ""
                
                for words in [firstNames.componentsSeparatedByString(" "), lastNames.componentsSeparatedByString(" ")] {
                    for word in words where word.lowercaseString.hasPrefix(searchText.lowercaseString) {
                        return true
                    }
                }
                
                return false
            }
            
            completionHandler(results: try? [User](js: filteredFriendsJSON) ?? [])
        }
    }
}