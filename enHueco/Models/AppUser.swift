//
//  AppUser.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class AppUser {

    class var sharedInstance: AppUser {
        struct Static {
            static var instance: AppUser?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AppUser()
        }
        
        return Static.instance!
    }
    
    var login : String?
    var token : String?
    var firstNames: String?
    var lastNames: String?
    var lastUpdatedOn: String?
    
    // Updates user if newer version is got.
    
    class func updateUser(newUser: AppUser)
    {
        
        sharedInstance.firstNames = newUser.firstNames
        sharedInstance.lastNames = newUser.lastNames
        sharedInstance.login = newUser.login
        
    }
    
    class func dictionaryToAppUser(dictionary : NSDictionary) -> AppUser?
    {
        
        var user : AppUser?
        user = AppUser()
        user!.login = dictionary["login"] as String?
        user!.firstNames = dictionary["firstNames"] as String?
        user!.lastNames = dictionary["lastNames"] as String?
        user!.lastUpdatedOn = dictionary["lastUpdated_on"] as NSString?
        return user!

        
        
    }
    
    
}

