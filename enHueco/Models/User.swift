//
//  User.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import CoreData

class User: PersistenceModel {

    @NSManaged var firstNames: String
    @NSManaged var login: String
    @NSManaged var lastNames: String
    @NSManaged var schedule: Schedule

}
