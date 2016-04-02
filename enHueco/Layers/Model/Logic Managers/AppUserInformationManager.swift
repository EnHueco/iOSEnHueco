//
//  AppUserInformationManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation

struct AppUserInformationManagerNotifications
{
    static let didReceiveAppUserInformationUpdates = "didReceiveAppUserInformationUpdates"
}

/** Handles fetching and sending of the AppUser's basic information like names, profile picture, username,
 phone number, and schedule. (Friends are not included)
*/
class AppUserInformationManager
{
    static let sharedManager = AppUserInformationManager()

    private init() {}

    /** Fetches the AppUser's basic information like names, profile picture URL, username,
     phone number, and schedule. (Friends are not included)
     */
    func fetchUpdatesForAppUserAndScheduleWithCompletionHandler(completionHandler: BasicCompletionHandler?)
    {
        let appUser = enHueco.appUser
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, successCompletionHandler: { (JSONResponse) -> () in
            
            let JSONDictionary = JSONResponse as! [String : AnyObject]
            
            // Doesn't really work for now
            
//            guard appUser.isOutdatedBasedOnDate(NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!) else
//            {
//                dispatch_async(dispatch_get_main_queue()) {
//                    completionHandler?(success: true, error: nil)
//                }
//                return
//            }

            let fetchedUpdatedOn = NSDate(serverFormattedString:JSONDictionary["updated_on"] as! String)!

            if appUser.isOutdatedBasedOnDate(fetchedUpdatedOn)
            {
                appUser.schedule = Schedule()
                appUser.updateUserWithJSONDictionary(JSONDictionary)

                let eventSet = JSONDictionary["gap_set"] as! [[String : AnyObject]]
                
                for eventJSON in eventSet
                {
                    let event = Event(JSONDictionary: eventJSON)
                    appUser.schedule.weekDays[event.localWeekDay()].addEvent(event)
                }
                try? PersistenceManager.sharedManager.persistData()
                AppUserInformationManager.sharedManager.downloadProfilePictureWithCompletionHandler(completionHandler)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(success: true, error: nil)
                }
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: false, error: error)
            }
        }
    }
    
    /// Sends a new image to the server and refreshes the pictureURL for the AppUser
    func pushProfilePicture(image: UIImage, completionHandler: BasicCompletionHandler?)
    {
        let url = NSURL(string: EHURLS.Base + EHURLS.MeImageSegment)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.setValue("attachment; filename=upload.jpg", forHTTPHeaderField: "Content-Disposition")
        
        let jpegData = NSData(data: UIImageJPEGRepresentation(image, 1)!)
        request.HTTPBody = jpegData
        
        ConnectionManager.sendAsyncDataRequest(request, successCompletionHandler: { (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: true, error: nil)
            }
            
            // self.fetchUpdatesForAppUserAndScheduleWithCompletionHandler(nil)
            
        }, failureCompletionHandler: { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: false, error: error)
            }
        })
    }
    
    func pushPhoneNumber(newNumber : String, completionHandler: BasicCompletionHandler?)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.HTTPMethod = "PUT"
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: ["phoneNumber":newNumber], successCompletionHandler: { (JSONResponse) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                completionHandler?(success: true, error: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(AppUserInformationManagerNotifications.didReceiveAppUserInformationUpdates, object: self)
            }
            
        }) { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: false, error: error)
            }
        }
    }
    
    /// Downloads the data for the pictureURL currently present in the AppUser
    func downloadProfilePictureWithCompletionHandler(completionHandler: BasicCompletionHandler?)
    {
        if let url = enHueco.appUser?.imageURL
        {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            
            ConnectionManager.sendAsyncDataRequest(request, successCompletionHandler: { (data) -> () in
                
                let path = PersistenceManager.sharedManager.documentsPath + "/profile.jpg"
                PersistenceManager.sharedManager.saveImage(data, path: path, successCompletionHandler: { () -> () in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(success: true, error: nil)
                    }
                })
            
            }) { (error) -> () in
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(success: false, error: error)
                }
            }
        }
    }
}