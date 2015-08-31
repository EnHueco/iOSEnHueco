//
//  AppUser.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class AppUser: User
{
    var token : String
    var lastUpdatedOn: String

    var friends = [User]()
    
    var friendRequests = [String]()
    
    init(username: String, token : String, lastUpdatedOn: String, firstNames: String, lastNames: String, phoneNumber: Int?, imageURL: String)
    {
        self.token = token
        self.lastUpdatedOn = lastUpdatedOn
        
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL)
    }
}

