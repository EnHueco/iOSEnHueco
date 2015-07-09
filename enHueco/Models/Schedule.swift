//
//  Schedule.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import CoreData

class Schedule: PersistenceModel {

    @NSManaged var jueves: Day
    @NSManaged var lunes: Day
    @NSManaged var martes: Day
    @NSManaged var miercoles: Day
    @NSManaged var viernes: Day

}
