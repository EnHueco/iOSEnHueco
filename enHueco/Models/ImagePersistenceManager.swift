//
//  ImagePersistenceManager.swift
//  enHueco
//
//  Created by Diego Gómez on 11/22/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ImagePersistenceManager{

    static func deleteImage(path:String)
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
    
    static func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    static func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = ImagePersistenceManager.getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    static func saveImage (data: NSData, path: String, onSuccess: () -> ()){
        
//        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            let result = data.writeToFile(path, atomically: true)
            if result
            {
                onSuccess()
            }
        }
    }
    
    static func loadImageFromPath(path: String, onFinish: (image: UIImage?) -> ()) {
        
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
