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
    let ID: String
    
    let firstName: String
    let lastName: String
    
    var name: String { return firstName + lastName }
    
    let photoURL: String
    var phoneNumber: Int?
    
    var schedule: Schedule
    
    init(ID: String, name: String, phoneNumber: Int? = nil)
    {
        self.ID = ID
        
        self.phoneNumber = phoneNumber
    }
}
