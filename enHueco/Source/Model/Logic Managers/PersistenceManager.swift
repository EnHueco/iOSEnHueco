//
//  PersistenceManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation

/// Handles all operations related to persistence.

class PersistenceManager {
    static let sharedManager = PersistenceManager()

    /// Lock to ensure thread safety
    private let lock = NSObject()

    enum PersistenceManagerError: ErrorType {
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
    func persistData() throws {

        defer {
            objc_sync_exit(lock)
        }

        objc_sync_enter(lock)

        if !(enHueco.appUser != nil && NSKeyedArchiver.archiveRootObject(enHueco.appUser, toFile: persistencePath)) {
            PersistenceManager.sharedManager.deleteAllPersistenceData()
            throw PersistenceManagerError.CouldNotPersistData
        }
    }

    /// Restores all pertinent application data to memory
    func loadDataFromPersistence() -> Bool {

        class UnArchiverDelegate: NSObject, NSKeyedUnarchiverDelegate {

            // This class is placeholder for unknown classes.
            // It will eventually be `nil` when decoded.

            final class Unknown: NSObject, NSCoding {
                @objc init?(coder aDecoder: NSCoder) {
                    super.init(); return nil
                }

                @objc func encodeWithCoder(aCoder: NSCoder) {

                }
            }

            @objc func unarchiver(unarchiver: NSKeyedUnarchiver, cannotDecodeObjectOfClassName name: String, originalClasses classNames: [String]) -> AnyClass? {

                return Unknown.self
            }
        }

        let removeAndFinish = {
            () -> Bool in
            let _ = try? NSFileManager.defaultManager().removeItemAtPath(self.persistencePath)
            return false
        }

        guard let data = NSData(contentsOfFile: persistencePath) else {
            return removeAndFinish()
        }

        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        let delegate = UnArchiverDelegate()
        unarchiver.delegate = delegate

        guard let appUser = unarchiver.decodeObjectForKey("root") as? AppUser else {
            return removeAndFinish()
        }

        enHueco.appUser = appUser
        return true
    }

    func deleteAllPersistenceData() {

        let fileManager = NSFileManager.defaultManager()

        let _ = try? fileManager.removeItemAtPath(persistencePath)

        if let directoryContents = try? fileManager.contentsOfDirectoryAtPath(documentsPath) {
            for path in directoryContents {
                let fullPath = (documentsPath as NSString).stringByAppendingPathComponent(path)
                let _ = try? fileManager.removeItemAtPath(fullPath)
            }
        }
    }

    func saveImage(data: NSData, path: String, successCompletionHandler: () -> ()) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            let result = data.writeToFile(path, atomically: true)

            if result {
                successCompletionHandler()
            }
        }
    }

    func loadImageFromPath(path: String, onFinish: (image:UIImage?) -> ()) {

        var image: UIImage? = nil
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