//
//  JSONToolkit.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation


class JSONToolkit{
    
    class func dictToJSONData(dictionary:NSDictionary) -> NSData{
        
        var jsonSerializationError : NSError?
        
        var jsonData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: &jsonSerializationError)

        return jsonData!
    }
    
    
    class func dictToJSONString(dictionary:NSDictionary) -> NSString{
        
        var jsonData = self.dictToJSONData(dictionary)
        var jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
        
        return jsonString!
    }
}