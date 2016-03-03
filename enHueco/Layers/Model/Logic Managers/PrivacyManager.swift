//
//  PrivacyManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/28/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation

enum PrivacySetting: String {
    
    case ShowEventsNames = "show_events_names"
    case ShowEventsLocation = "show_events_locations"
    case ShowUserIsNearby = "show_user_is_nearby"
}

/// Policy applied to the group of friends it accepts for parameter.
enum PrivacyPolicy {
    
    case EveryoneExcept([User]), Only([User])
}

class PrivacyManager
{
    private init() {}
    
    /// Turns a setting off (e.g. If called as "turnPrivacySettingOff(.ShowEventsNames)", nobody will be able to see the names of the user's events.
    class func turnOffSetting(setting: PrivacySetting, withCompletionHandler completionHandler: (success: Bool, error: ErrorType?) -> Void)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "PUT"
        
        let parameters = [setting.rawValue : "false"]
        
        ConnectionManager.sendAsyncDataRequest(request, withJSONParams: parameters, onSuccess: { (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }
            
            }) { (compoundError) -> () in
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: false, error: compoundError.error)
                }
        }
    }

    /**
     Turns a setting on for a given policy applied to a group of friends. This replaces the previous setting that the user had.
     
     - parameter setting:           Setting to update
     - parameter policy:            Policy applied to the group of friends it accepts for parameter. For example, a method call like
                                    "turnOnSetting(.ShowNearby, `for`: .EveryoneExcept(aGroup), withCompletionHandler: ...)" will show to everyone except the members of "aGroup"
                                    that the user is nearby if both indeed are.
     */
    class func turnOnSetting(setting: PrivacySetting, `for` policy: PrivacyPolicy? = nil, withCompletionHandler completionHandler: (success: Bool, error: ErrorType?) -> Void)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.MeSegment)!)
        request.setEHSessionHeaders()
        request.HTTPMethod = "PUT"
        
        let parameters = [setting.rawValue : "true"]
        
        ConnectionManager.sendAsyncDataRequest(request, withJSONParams: parameters, onSuccess: { (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, error: nil)
            }

        }) { (compoundError) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: false, error: compoundError.error)
            }
        }
    }
}