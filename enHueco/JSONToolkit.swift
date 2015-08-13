//
//  JSONToolkit.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation


class JSONToolkit
{
    class func dictToJSONData(dictionary:NSDictionary) -> NSData?
    {
        do
        {
            return try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch
        {
            return nil
        }
    }
    
    class func dictToJSONString(dictionary:NSDictionary) -> NSString?
    {
        guard let jsonData = dictToJSONData(dictionary) else { return nil }
        
        return NSString(data: jsonData, encoding: NSUTF8StringEncoding)
    }
}