//
//  PersistenceManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation

/// Handles all operations related to persistence.
class PersistenceManager
{
    static let sharedManager = PersistenceManager()

    /// Lock to ensure thread safety
    private let lock = NSObject()
    
    enum PersistenceManagerError: ErrorType
    {
        case CouldNotPersistData
    }
    
    /// Path to the documents folder
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    /// Path where data will be persisted
    private let persistencePath: String!
    
    private init() {
        
        persistencePath = documentsPath + "/appState.state"
    }
    
    /// Persists all pertinent application data
    func persistData () throws
    {
        defer { objc_sync_exit(lock) }
        
        objc_sync_enter(lock)
            
        if !(enHueco.appUser != nil && NSKeyedArchiver.archiveRootObject(enHueco.appUser, toFile: persistencePath))
        {
            PersistenceManager.sharedManager.deleteAllPersistenceData()
            throw PersistenceManagerError.CouldNotPersistData
        }
    }
    
    /// Restores all pertinent application data to memory
    func loadDataFromPersistence () -> Bool
    {
        enHueco.appUser = NSKeyedUnarchiver.unarchiveObjectWithFile(persistencePath) as? AppUser
        
        if enHueco.appUser == nil
        {
            try? NSFileManager.defaultManager().removeItemAtPath(persistencePath)
        }
        
        return enHueco.appUser != nil
    }

    func deleteAllPersistenceData()
    {
        try? NSFileManager.defaultManager().removeItemAtPath(persistencePath)
        try? NSFileManager.defaultManager().removeItemAtPath(PersistenceManager.sharedManager.documentsPath + "profile.jpg")
    }
    
    func saveImage (data: NSData, path: String, successCompletionHandler: () -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let result = data.writeToFile(path, atomically: true)
            
            if result
            {
                successCompletionHandler()
            }
        }
    }
    
    func loadImageFromPath(path: String, onFinish: (image: UIImage?) -> ())
    {
        var image : UIImage? = nil
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            image = UIImage(contentsOfFile: path)
            if image == nil {
                print("Missing image at: \(path)")
            }
            print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
            onFinish(image: image)
        }
    }
}