//
//  UserUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

struct UserUpdateIntent: MappableBase {

    var institution: String?
    var firstNames: String?
    var lastNames: String?
    var image: URL?
    var imageThumbnail: URL?
    var phoneNumber: String?
    var gender: Gender?
    
    init() {}

    init(node: Node, in context: Context) throws {
        throw GenericError.unsupportedOperation
    }
        
    func sequence(_ map: Map) throws {

        typealias JSONKeys = User.JSONKeys

        try institution ~> map[JSONKeys.institution]
        try firstNames?.components(separatedBy: " ") ~> map[JSONKeys.firstNames]
        try lastNames?.components(separatedBy: " ") ~> map[JSONKeys.lastNames]
        try image ~> map[JSONKeys.image]
        try imageThumbnail ~> map[JSONKeys.imageThumbnail]
        try phoneNumber ~> map[JSONKeys.phoneNumber]
        try gender ~> map[JSONKeys.gender]
    }
}
