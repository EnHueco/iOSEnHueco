//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class HTTPRequestResponseManager: NSObject{
    
    class var GET : NSString {return "GET"}
    class var POST : NSString {return "POST"}
    
    
    func sendRequest(url: NSURL, method:String, dictionary:NSDictionary, successfulRequestBlock:(NSData)->(), failureRequestBlock:(NSError)->() )
    {
        var dictionaryJSONData = JSONToolkit.dictToJSONData(dictionary)
        var request = NSMutableURLRequest(URL: url)
        var string = JSONToolkit.dictToJSONString(dictionary)
        
        request.HTTPMethod = HTTPRequestResponseManager.POST
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
//        request.HTTPBody = dictionaryJSON
        
        var queue : NSOperationQueue = NSOperationQueue()


        NSURLConnection.sendAsynchronousRequest(request, queue: queue)
            {
                (response: NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                
                if data != nil && error == nil
                {
                    successfulRequestBlock(data)
                }
                else
                {
                    failureRequestBlock(error)
                }
                
            }
    }
}


protocol HTTPRequestResponseManagerProtocol{

    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)

}
