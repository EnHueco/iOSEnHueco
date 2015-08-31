//
//  Friend.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class User: NSObject
{
    let username: String
    
    let firstNames: String
    let lastNames: String
    
    var name: String { return firstNames + lastNames }
    
    let imageURL: String
    var phoneNumber: Int?
    
    var schedule: Schedule?
    
    init(username: String, firstNames: String, lastNames: String, phoneNumber: Int? = nil, imageURL: String)
    {
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        
        super.init()
    }
}
