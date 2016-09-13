//
//  UserUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

struct UserUpdateIntent: MappableBase {

    var institution: String?
    var firstNames: String?
    var lastNames: String?
    var image: NSURL?
    var imageThumbnail: NSURL?
    var phoneNumber: String?
    var gender: Gender?

    static func newInstance(json: Json, context: Context) throws -> UserUpdateIntent {
        throw GenericError.UnsupportedOperation
    }
    
    func sequence(map: Map) throws {

        typealias JSONKeys = User.JSONKeys

        try institution ~> map[.Key(JSONKeys.institution)]
        try firstNames?.componentsSeparatedByString(" ") ~> map[.Key(JSONKeys.firstNames)]
        try lastNames?.componentsSeparatedByString(" ") ~> map[.Key(JSONKeys.lastNames)]
        try image ~> map[.Key(JSONKeys.image)]
        try imageThumbnail ~> map[.Key(JSONKeys.imageThumbnail)]
        try phoneNumber ~> map[.Key(JSONKeys.phoneNumber)]
        try gender ~> map[.Key(JSONKeys.gender)]
    }
}