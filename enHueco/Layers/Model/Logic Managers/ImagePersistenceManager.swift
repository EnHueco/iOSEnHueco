//
//  ImagePersistenceManager.swift
//  enHueco
//
//  Created by Diego Gómez on 11/22/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ImagePersistenceManager
{
    private static let instance = ImagePersistenceManager()

    private init() {}
    
    class func sharedManager() -> ImagePersistenceManager
    {
        return instance
    }

    func deleteImage(path:String)
    {
        do
        {
            try NSFileManager.defaultManager().removeItemAtPath(path)
            print("Deleted file: \(path)")
        }
        catch
        {
            print("Error \(error)")
        }
        
    }
    
    func getDocumentsURL() -> NSURL
    {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String
    {
        let fileURL = ImagePersistenceManager.sharedManager().getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    func saveImage (data: NSData, path: String, onSuccess: () -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            let result = data.writeToFile(path, atomically: true)
            if result
            {
                onSuccess()
            }
        }
    }
    
    func loadImageFromPath(path: String, onFinish: (image: UIImage?) -> ())
    {
        var image : UIImage? = nil
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            image = UIImage(contentsOfFile: path)
            if image == nil {
                print("Missing image at: \(path)")
            }
            print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
            onFinish(image: image)
        }
    }
}
