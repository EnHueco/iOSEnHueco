//
//  GenomeTransformers.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/28/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import PureJsonSerializer

struct GenomeTransformers
{
    static func fromJSON(value: String) throws -> NSURL {
        guard let mapped = NSURL(string: value) else {
            throw GenericError.Error(message: "Could not map URL. Found \(value)")
        }
        return mapped
    }
    
    static func fromJSON(value: Double) throws -> NSDate {
        return NSDate(timeIntervalSince1970: value)
    }
    
    static func fromJSON<T: RawRepresentable>(value: Json) throws -> T {
        guard let rawValue = value.anyValue as? T.RawValue,
              let mapped = T(rawValue: rawValue) else {
            
                throw GenericError.Error(message: "Could not map URL. Found \(value)")
        }
        return mapped
    }
    
    static func toJSON(value: NSURL?) -> Json {
        guard let value = value?.absoluteString else { return Json.NullValue }
        return Json(value)
    }
        
    static func toJSON<T: RawRepresentable>(value: T?) -> Json {
        guard let value = value?.rawValue else { return Json.NullValue }
        return Json(String(value))
    }
    
    static func toJSON(value: NSDate?) -> Json {
        guard let value = value?.timeIntervalSince1970 else { return Json.NullValue }
        return Json(value)
    }
}