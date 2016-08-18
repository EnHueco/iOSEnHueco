//
//  PrivacyUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

struct PrivacyUpdateIntent: MappableObject {

    var showEventsNames: Bool?
    var showEventsLocations: Bool?

    func sequence(map: Map) throws {

        typealias JSONKeys = PrivacySettings.JSONKeys

        institution ~> map[JSONKeys.institution]
        firstNames ~> map[JSONKeys.firstNames]
        lastNames ~> map[JSONKeys.lastNames]
        image ~> map[JSONKeys.image]
        imageThumbnail ~> map[JSONKeys.imageThumbnail]
        phoneNumber ~> map[JSONKeys.phoneNumber]
    }
}