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
import SwiftyJSON

class FriendsManager: FirebaseLogicManager {

    fileprivate init() {}

    static let shared = FriendsManager()

    /// Deletes a friend.
    func deleteFriend(id friendID: String, completionHandler: @escaping BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(completionHandler)?.uid else { return }

        let update = [
            appUserID + "/" + friendID : NSNull(),
            friendID + "/" + appUserID : NSNull()
        ]
        
        FIRDatabase.database().reference().child(FirebasePaths.friends).updateChildValues(update) { (error, reference) in
            DispatchQueue.main.async{
                completionHandler(error)
            }
        }
    }

    /// Sends a friend request to the username provided and notifies the result via Notification Center.
    func sendFriendRequestTo(id friendID: String, completionHandler: @escaping BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(completionHandler)?.uid else { return }
        
        let update = [
            FirebasePaths.sentRequests + "/" + appUserID : friendID,
            FirebasePaths.receivedRequests + "/" + friendID : appUserID
        ]
        
        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            DispatchQueue.main.async{
                completionHandler(error)
            }
        }
    }
    
    /// Accepts friend request from the friend id provided.
    func acceptFriendRequestFrom(id friendID: String, completionHandler: @escaping BasicCompletionHandler) {
        
        guard let appUserID = firebaseUser(completionHandler)?.uid else { return }

        let update = [
            FirebasePaths.receivedRequests + "/" + appUserID + "/" + friendID : NSNull(),
            FirebasePaths.sentRequests + "/" + friendID + "/" + appUserID  : NSNull(),
            FirebasePaths.friends + "/" + appUserID : friendID,
            FirebasePaths.friends + "/" + friendID : appUserID
        ] as [String : Any]

        FIRDatabase.database().reference().updateChildValues(update) { (error, reference) in
            DispatchQueue.main.async{
                completionHandler(error)
            }
        }
    }
    
    func fetchUserWithID(_ id: String, completionHandler: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        fetchUsersWithIDs([id]) { (users, error) in
            completionHandler(users?.first, error)
        }
    }
    
    func fetchUsersWithIDs(_ ids: [String], completionHandler: @escaping (_ users: [User]?, _ error: Error?) -> Void) {
                
        var errorOccurred = false
        var users = [User]()
        
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        
        for id in ids {
            
            FIRDatabase.database().reference().child(FirebasePaths.users).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                queue.async {
                    guard !errorOccurred else { return }
                    
                    guard let valueJSON = snapshot.value, let user = try? User(node: valueJSON) else {
                        DispatchQueue.main.async{
                            errorOccurred = true
                            completionHandler(nil, GenericError.unknownError)
                        }
                        return
                    }
                    
                    users.append(user)
                    
                    if users.count == ids.count {
                        DispatchQueue.main.async {
                            completionHandler(users, nil)
                        }
                    }
                }
                
            }, withCancel: { (error) in
                
                queue.async {
                    guard !errorOccurred else { return }

                    errorOccurred = true
                    
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            })
        }
    }
    
    /**
     Performs a search for users based on their name
     
     - parameter searchText:        Text to search
     */
    func searchUsersByName(_ searchText: String, institutionID: String?, completionHandler: @escaping (_ results:[User]) -> ()) {
        
        guard !searchText.isBlank() else {
            DispatchQueue.main.async { completionHandler([User]()) }
            return
        }
        
        FIRDatabase.database().reference().child(FirebasePaths.users).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            let json = JSON(snapshot.value ?? [:])
            
            let filteredFriendsJSON = json.arrayValue.filter {
                
                let firstNames = $0[User.JSONKeys.firstNames].stringValue
                let lastNames = $0[User.JSONKeys.lastNames].stringValue
                
                for words in [firstNames.components(separatedBy: " "), lastNames.components(separatedBy: " ")] {
                    for word in words where word.lowercased().hasPrefix(searchText.lowercased()) {
                        return true
                    }
                }
                
                return false
            }
            
            let array = filteredFriendsJSON.map { $0.object }
            completionHandler((try? [User](node: array)) ?? [])
        }
    }
}
