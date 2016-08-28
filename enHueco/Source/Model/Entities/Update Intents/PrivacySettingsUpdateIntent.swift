//
//  PrivacyUpdateIntent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

struct PrivacyUpdateIntent: BasicMappable {

    var showEventsNames: Bool?
    var showEventsLocations: Bool?

    func sequence(map: Map) throws {

        typealias JSONKeys = PrivacySettings.JSONKeys

        try showEventsNames ~> map[.Key(JSONKeys.showEventsNames)]
        try showEventsLocations ~> map[.Key(JSONKeys.showEventsLocations)]
    }
}