//
//  PrivacyManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/28/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

/**
 Available privacy settings
 
 - ShowEventNames:    If event names will be shown to a given group
 - ShowEventLocation: If event locations will be shown to a given group
 - ShowUserIsNearby:  If a given group can find out that the AppUser is nearby
 */
enum PrivacySetting: String
{
    case ShowEventNames = "shares_event_names"
    case ShowEventLocation = "shares_event_locations"
    case ShowUserIsNearby = "shares_user_nearby"
}

/// Policy applied to the group of friends it accepts for parameter.
enum PrivacyPolicy
{
    case EveryoneExcept([User]), Only([User])
}

/// Handles privacy settings
class PrivacyManager
{
    private static let instance = PrivacyManager()
    
    private init() {}
    
    class func sharedManager() -> PrivacyManager
    {
        return instance
    }
    
    /// Turns a setting off (e.g. If called as "turnOffSetting(.ShowEventsNames)", nobody will be able to see the names of the user's events.
    func turnOffSetting(setting: PrivacySetting, withCompletionHandler completionHandler: BasicCompletionHandler)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "PUT"
        
        let parameters = [setting.rawValue : "false"]
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: parameters, onSuccess: { (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, onFailure: { (compoundError) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }
    
    /**
     Turns a setting on for a given policy applied to a group of friends. This replaces the previous setting that the user had.
     
     - parameter setting:           Setting to update
     - parameter policy:            Policy applied to the group of friends it accepts for parameter. For example, a method call like
     "turnOnSetting(.ShowNearby, `for`: .EveryoneExcept(aGroup), withCompletionHandler: ...)" will show to everyone except the members of "aGroup"
     that the user is nearby if both indeed are.
     
     If policy nil the setting is applied to everyone
     */
    func turnOnSetting(setting: PrivacySetting, `for` policy: PrivacyPolicy? = nil, withCompletionHandler completionHandler: BasicCompletionHandler)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "PUT"
        
        let parameters = [setting.rawValue : "true"]
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: parameters, onSuccess: { (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, onFailure: { (compoundError) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }
    
    /// Makes the user invisible to everyone else
    func turnInvisibleForTimeInterval(timeInterval: NSTimeInterval, completionHandler: BasicCompletionHandler)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.ImmediateEventsSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "PUT"
        
        let instantEvent =
        [
            "type" : "INVISIBILITY",
            "valid_until" : NSDate().dateByAddingTimeInterval(timeInterval).serverFormattedString()
        ]
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: instantEvent, onSuccess: { (JSONResponse) -> () in
            
            enHueco.appUser.invisible = true
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, onFailure: {(compoundError) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }
    
    /// Makes the user visible to everyone else
    func turnVisibleWithCompletionHandler(completionHandler: BasicCompletionHandler)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.ImmediateEventsSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "PUT"
        
        let instantEvent =
        [
            "type" : "INVISIBILITY",
            "valid_until" : NSDate()
        ]
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: instantEvent, onSuccess: { (JSONResponse) -> () in
            
            enHueco.appUser.invisible = false
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
        }, onFailure: {(compoundError) -> () in
                
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        })
    }
}