//
//  System.swift
//  enHueco
//
//  Created by Diego Montoya on 7/15/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

let system = System()

class EHSystemNotification
{
    static let SystemDidLogin = "SystemDidLogin", SystemCouldNotLoginWithError = "SystemCouldNotLoginWithError"
    static let SystemDidReceiveFriendAndScheduleUpdates = "SystemDidReceiveFriendAndScheduleUpdates"
    static let SystemDidReceiveFriendRequestUpdates = "SystemDidReceiveFriendRequestUpdates"
    static let SystemDidAddFriend = "SystemDidAddFriend"
    static let SystemDidSendFriendRequest = "SystemDidSendFriendRequest", SystemDidFailToSendFriendRequest = "SystemDidFailToSendFriendRequest"
}

class System
{
    enum SystemError: ErrorType
    {
        case CouldNotPersistData
    }
    
    
    /// Path to the documents folder
    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    
    /// Path where data will be persisted
    let persistancePath: String
    

    /// User of the app
    var appUser: AppUser!
    
    private init()
    {
        persistancePath = documents + "/appState.state"
        
        if !loadDataFromPersistence()
        {
            
        }
    }
    
    func createTestAppUser ()
    {
        //Pruebas
        
        appUser = AppUser(username: "pa.perez10", token: "adfsdf", firstNames: "Diego", lastNames: "Montoya Sefair", phoneNumber: "3176694189", imageURL: NSURL(string: "https://fbcdn-sphotos-a-a.akamaihd.net/hphotos-ak-xap1/t31.0-8/1498135_821566567860780_1633731954_o.jpg")!, ID:"pa.perez10", lastUpdatedOn: NSDate())

        
        //////////
    }
    
    /**
    Checks for updates on the server including Session Status, Friend list, Friends Schedule, User's Info
    */
    func checkForUpdates ()
    {
        
    }
    
    /** 
    Logs user in for the first time or when session expires. Creates or replaces the AppUser. Notifies the result via Notification Center.
    
    ### Notifications
    - EHSystemNotification.SystemDidLogin in case of success
    - EHSystemNotification.SystemCouldNotLoginWithError in case of failure
    */
    func login (username: String, password: String)
    {
        let params = ["user_id":username, "password":password]
        let URL = NSURL(string: EHURLS.Base + EHURLS.AuthSegment)!
        
        ConnectionManager.sendAsyncRequestToURL(URL, usingMethod: .POST, withJSONParams: params, onSuccess: { (response) -> () in
            
            guard let token = response["value"] as? String else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemCouldNotLoginWithError, object: self, userInfo: ["error": "Response received but token missing"])
                return
            }
            
            let user = response["user"] as! [String : String]
            let username = user["login"] as String!
            let firstNames = user["firstNames"] as String!
            let lastNames = user["lastNames"] as String!
            let imageURL = NSURL(string: user["imageURL"] as String!)
            let lastUpdatedOn = NSDate(serverFormattedString: user["lastUpdated_on"] as String!)!
            
            //TODO: Asign lastUpdatedOn
            
            let appUser = AppUser(username: username, token: token, firstNames: firstNames, lastNames: lastNames, phoneNumber: nil, imageURL: imageURL, ID: username, lastUpdatedOn: lastUpdatedOn)
            
            self.appUser = appUser
            
            //self.updateFriendsAndFriendsSchedules()
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidLogin, object: self, userInfo: nil)
            
        }) { (error) -> () in
            
            NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemCouldNotLoginWithError, object: self, userInfo: ["error": error as! AnyObject])
        }
    }
    
    func logOut()
    {
        // TODO: Delete persistence information, send logout notification to server so token is deleted.
        
        do
        {
            appUser = nil
            try NSFileManager.defaultManager().removeItemAtPath(persistancePath)
        }
        catch
        {
            
        }
    }

    /// Persists all pertinent application data
    func persistData () throws
    {
        guard NSKeyedArchiver.archiveRootObject(appUser, toFile: persistancePath) else
        {
            throw SystemError.CouldNotPersistData
        }
    }
    
    /// Restores all pertinent application data to memory
    func loadDataFromPersistence () -> Bool
    {
        appUser = NSKeyedUnarchiver.unarchiveObjectWithFile(persistancePath) as? AppUser
        
        return appUser != nil
    }
}