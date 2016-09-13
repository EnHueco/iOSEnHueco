//
//  GenomeTransformers.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/28/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

extension NSDate: JsonConvertibleType {
    
    public static func newInstance(json: Json, context: Context) throws -> Self {
        
        guard let value = json.doubleValue else {
            throw GenericError.Error(message: "Could not map URL. Found \(self)")
        }
        
        return self.init(timeIntervalSince1970: value)
    }
    
    public func jsonRepresentation() throws -> Json {
        return Json(timeIntervalSince1970)
    }
}

extension RawRepresentable {
    
    public static func newInstance(json: Json, context: Context) throws -> Self {
        
        guard let rawValue = json.anyValue as? RawValue, let mapped = Self(rawValue: rawValue) else {
            throw GenericError.Error(message: "Could not map RawRepresentable. Found \(self)")
        }
        
        return mapped
    }
    
    public func jsonRepresentation() throws -> Json {
        return Json(String(rawValue))
    }
}

extension NSURL: JsonConvertibleType {
    
    public static func newInstance(json: Json, context: Context) throws -> Self {
        
        guard let value = json.stringValue, let mapped = self.init(string: value) else {
            throw GenericError.Error(message: "Could not map URL. Found \(self)")
        }
        
        return mapped
    }
    
    public func jsonRepresentation() throws -> Json {
        return Json(absoluteString)
    }
}