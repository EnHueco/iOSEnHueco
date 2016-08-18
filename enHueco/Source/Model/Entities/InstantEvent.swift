//
//  InstantEvent.swift
//  enHueco
//
//  Created by Diego Gómez on 8/12/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

/// The type of the Instant Event
enum InstantEventType: String
{
    case FreeTime = "FREE_TIME", Invisible = "INVISIBLE"
}
class InstantEvent
{
    let userID: String
    
    let type : InstantEventType
    
    let name: String
    
    let startDate: NSDateComponents
    
    let endDate: NSDateComponents
    
    let location: NSString
    
    //var name: String { return "\(firstNames) \(lastNames)" }
    
    init(map: Map) throws {
        userID = try map.extract("user_id")
        type = try map["type"].fromJson { EventType(rawValue: $0)! }
        name = try map.extract("name")
        
        // To do: Set start & end dates based on JSON data
        location = try map.extract("location")
    }
}
