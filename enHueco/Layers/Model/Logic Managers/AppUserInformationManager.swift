//
//  AppUserInformationManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation

/** Handles fetching and sending of the AppUser's basic information like names, profile picture, username,
 phone number, and schedule. (Friends are not included)
*/
class AppUserInformationManager
{
    private static let instance = AppUserInformationManager()

    private init() {}
    
    class func sharedManager() -> AppUserInformationManager
    {
        return instance
    }

    //TODO: What is this method for?
    func fetchAppUser ()
    {
        let appUser = enHueco.appUser
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            let downloadedUser = JSONResponse as! [String : AnyObject]
            
            if appUser.isOutdatedBasedOnDate(NSDate(serverFormattedString: downloadedUser["updated_on"] as! String)!)
            {
                appUser.updateUserWithJSONDictionary(downloadedUser)
                
                try? PersistenceManager.sharedManager().persistData()

                AppUserInformationManager.sharedManager().downloadProfilePictureWithCompletionHandler(nil)
            }
            
        }) { (error) -> () in
            
            
        }
    }

    /** Fetches the AppUser's basic information like names, profile picture URL, username,
     phone number, and schedule. (Friends are not included)
     */
    func fetchUpdatesForAppUserAndSchedule ()
    {
        let appUser = enHueco.appUser
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.HTTPMethod = "GET"
        
        ConnectionManager.sendAsyncRequest(request, onSuccess: { (JSONResponse) -> () in
            
            let JSONDictionary = JSONResponse as! [String : AnyObject]
            appUser.updateUserWithJSONDictionary(JSONDictionary)
            
            appUser.schedule = Schedule()
            let eventSet = JSONDictionary["gap_set"] as! [[String : AnyObject]]
            
            for eventJSON in eventSet
            {
                let event = Event(JSONDictionary: eventJSON)
                appUser.schedule.weekDays[event.localWeekDay()].addEvent(event)
            }
            
        }) { (error) -> () in
            
        }
    }
    
    func pushProfilePicture(image: UIImage, completionHandler: BasicCompletionHandler?)
    {
        let url = NSURL(string: EHURLS.Base + EHURLS.MeImageSegment)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.setValue("attachment; filename=upload.jpg", forHTTPHeaderField: "Content-Disposition")
        
        let jpegData = NSData(data: UIImageJPEGRepresentation(image, 1)!)
        request.HTTPBody = jpegData
        
        ConnectionManager.sendAsyncDataRequest(request, onSuccess: { (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: true, error: nil)
            }
            
            self.fetchAppUser()
            
        }, onFailure: { (error) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: false, error: error)
            }
        })
    }
    
    func downloadProfilePictureWithCompletionHandler(completionHandler: BasicCompletionHandler?)
    {
        if let url = enHueco.appUser?.imageURL
        {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            
            ConnectionManager.sendAsyncDataRequest(request, onSuccess: { (data) -> () in
                
                let path = PersistenceManager.sharedManager().documentsPath + "/profile.jpg"
                PersistenceManager.sharedManager().saveImage(data, path: path, onSuccess: { () -> () in
                    
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