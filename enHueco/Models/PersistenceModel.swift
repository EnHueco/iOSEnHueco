//
//  PersistenceModel.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import CoreData

class PersistenceModel: NSManagedObject {

    @NSManaged var persistenceStatus: NSNumber
    @NSManaged var lastUpdatedOn: NSDate

}
