//
//  System.swift
//  enHueco
//
//  Created by Diego Montoya on 7/15/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import CoreLocation
import SystemConfiguration.CaptiveNetwork

/// Universally accessible singleton instance
let system = System()

class EHSystemNotification
{
    static let SystemDidLogin = "SystemDidLogin", SystemCouldNotLoginWithError = "SystemCouldNotLoginWithError"
    static let SystemDidReceiveFriendAndScheduleUpdates = "SystemDidReceiveFriendAndScheduleUpdates"
    static let SystemDidReceiveFriendRequestUpdates = "SystemDidReceiveFriendRequestUpdates"
    static let SystemDidAddFriend = "SystemDidAddFriend"
    static let SystemDidSendFriendRequest = "SystemDidSendFriendRequest", SystemDidFailToSendFriendRequest = "SystemDidFailToSendFriendRequest"
    static let SystemDidAcceptFriendRequest = "SystemDidAcceptFriendRequest", SystemDidFailToAcceptFriendRequest = "SystemDidFailToAcceptFriendRequest"
    static let SystemDidReceiveAppUserImage = "SystemDidReceiveAppUserImage"
    
    static let SystemDidReceiveAppUserWasUpdated = "SystemDidReceiveAppUserWasUpdated"
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
    let persistencePath: String
    
    /// User of the app
    var appUser: AppUser!
    
    private init()
    {
        persistencePath = documents + "/appState.state"
        
        loadDataFromPersistence()        
    }
    
    func createTestAppUser ()
    {
        //Pruebas
        
        appUser = AppUser(username: "pa.perez10", token: "adfsdf", firstNames: "Diego", lastNames: "Montoya Sefair", phoneNumber: "3176694189", imageURL: NSURL(string: "https://fbcdn-sphotos-a-a.akamaihd.net/hphotos-ak-xap1/t31.0-8/1498135_821566567860780_1633731954_o.jpg")!, ID:"pa.perez10", lastUpdatedOn: NSDate())

        let friend = User(username: "da.gomez11", firstNames: "Diego Alejandro", lastNames: "Gómez Mosquera", phoneNumber: "3176694189", imageURL: NSURL(string: "https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xat1/v/t1.0-9/1377456_10152974578604740_7067096578609392451_n.jpg?oh=89245c25c3ddaa4f7d1341f7788de261&oe=56925447&__gda__=1448954703_30d0fe175a8ab0b665dc074d63a087d6")!, ID:"da.gomez11", lastUpdatedOn: NSDate())
        let start = NSDateComponents(); start.hour = 0; start.minute = 00
        let end = NSDateComponents(); end.hour = 1; end.minute = 00
        let gap = Event(type:.Gap, startHour: start, endHour: end)
        friend.schedule.weekDays[6].addEvent(gap)
        appUser.friends[friend.username] = friend
        
        appUser.friends[appUser.username] = appUser

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

            self.appUser = AppUser(JSONDictionary: response as! [String : AnyObject])
            
            self.appUser.downloadProfilePicture()
            
            self.appUser.fetchUpdatesForAppUserAndSchedule()
            
            self.appUser.fetchUpdatesForFriendsAndFriendSchedules()
            
            try! self.persistData()
            
            dispatch_async(dispatch_get_main_queue())
            {

                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemDidLogin, object: self, userInfo: nil)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue())
            {
                print(error.error)
                
                NSNotificationCenter.defaultCenter().postNotificationName(EHSystemNotification.SystemCouldNotLoginWithError, object: self, userInfo: nil)
            }
        }
    }
    
    func logOut()
    {
        // TODO: Delete persistence information, send logout notification to server so token is deleted.
        
        do
        {
            appUser = nil
            ImagePersistenceManager.deleteImage(ImagePersistenceManager.fileInDocumentsDirectory("profile.jpg"))
            try NSFileManager.defaultManager().removeItemAtPath(persistencePath)
        }
        catch
        {
            
        }
    }
    
    func searchUsersWithText (searchText: String, completionHandler: (results: [User])->())
    {
        guard !searchText.isBlank() else
        {
            dispatch_async(dispatch_get_main_queue())
            {
                completionHandler(results: [User]())
            }

            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.UsersSegment + searchText)!)
        request.setValue(appUser.username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(appUser.token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "GET"

        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            var userSearchResults = [User]()
            
            for userJSON in JSONResponse as! [[String : AnyObject]]
            {
                userSearchResults.append(User(JSONDictionary: userJSON))
            }
            
            dispatch_async(dispatch_get_main_queue())
            {
                completionHandler(results: userSearchResults)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue())
            {
                completionHandler(results: [User]())
            }
        }
    }
    
    /// Persists all pertinent application data
    func persistData () throws
    {
        guard appUser != nil && NSKeyedArchiver.archiveRootObject(appUser, toFile: persistencePath) else
        {
            throw SystemError.CouldNotPersistData
        }
    }
    
    /// Restores all pertinent application data to memory
    func loadDataFromPersistence () -> Bool
    {
        appUser = NSKeyedUnarchiver.unarchiveObjectWithFile(persistencePath) as? AppUser
        
        if appUser == nil
        {
            try? NSFileManager.defaultManager().removeItemAtPath(persistencePath)
        }
        
        return appUser != nil
    }
    
    func callFriend(phoneNumber : String)
    {
        let url:NSURL = NSURL(string: "tel://\(phoneNumber)")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func whatsappMessageTo(friendABID : NSNumber?)
    {
        let url: NSURL = NSURL(string: "whatsapp://send?" + ((friendABID == nil) ? "": "abid=\(friendABID!)"))!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func getFriendABID(phoneNumber : String, onSuccess : (NSNumber) -> ())
    {
        let addressBook = APAddressBook()
        addressBook.fieldsMask =  APContactField.Phones.union(APContactField.RecordID)
        var abid : NSNumber? = nil
        addressBook.loadContacts(
            { (contacts: [AnyObject]!, error: NSError!) in
                
                if contacts != nil
                {
                    for contact in contacts
                    {
                        if let contactAP = contact as? APContact
                        {
                            for phone in contactAP.phones
                            {
                                if var phoneString = phone as? String
                                {
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString("(", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString(")", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString("-", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString("+", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
                                    
                                    if phoneString.rangeOfString(phoneNumber) != nil
                                    {
                                        abid = contactAP.recordID
                                        onSuccess(abid!)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
        })
        return
    }
}