//
//  Class.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class Class: NSObject
{
    var startHour: NSDateComponents
    var endHour: NSDateComponents
    
    var location: String?
    
    init(startHour: NSDateComponents, endHour: NSDateComponents, location: String? = nil)
    {
        self.startHour = startHour
        self.endHour = endHour
        
        self.location = location
        
        super.init()
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let startHour = decoder.decodeObjectForKey("startHour") as? NSDateComponents,
            let endHour = decoder.decodeObjectForKey("endHour") as? NSDateComponents
        else
        {
            self.startHour = NSDateComponents()
            self.endHour = NSDateComponents()
            
            super.init()
            return nil
        }
        
        self.startHour = startHour
        self.endHour = endHour
        self.location = decoder.decodeObjectForKey("location") as? String

        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(startHour, forKey: "startHour")
        coder.encodeObject(endHour, forKey: "endHour")
    }
}
