//
//  PersistenceManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation

class PersistenceManager
{
    private init() {}

    enum PersistenceManagerError: ErrorType
    {
        case CouldNotPersistData
    }
    
    /// Path to the documents folder
    static private let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    /// Path where data will be persisted
    static private let persistencePath = documents + "/appState.state"
    
    /// Persists all pertinent application data
    class func persistData () throws
    {
        guard enHueco.appUser != nil && NSKeyedArchiver.archiveRootObject(enHueco.appUser, toFile: persistencePath) else
        {
            throw PersistenceManagerError.CouldNotPersistData
        }
    }
    
    /// Restores all pertinent application data to memory
    class func loadDataFromPersistence () -> Bool
    {
        enHueco.appUser = NSKeyedUnarchiver.unarchiveObjectWithFile(persistencePath) as? AppUser
        
        if enHueco.appUser == nil
        {
            try? NSFileManager.defaultManager().removeItemAtPath(persistencePath)
        }
        
        return enHueco.appUser != nil
    }

    class func deleteAllPersistenceData()
    {
        try? NSFileManager.defaultManager().removeItemAtPath(persistencePath)
    }
}