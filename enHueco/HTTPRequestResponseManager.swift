//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class HTTPRequestResponseManager: NSObject
{
    class var GET : String { return "GET" }
    class var POST : String { return "POST" }
    
    func sendRequest(url: NSURL, method:String, dictionary:NSDictionary, successfulRequestBlock:(NSData)->(), failureRequestBlock:(NSError)->() )
    {
        let dictionaryJSONData = JSONToolkit.dictToJSONData(dictionary)
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPRequestResponseManager.POST
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response, data, error) -> Void in
            
            if let data = data where error == nil
            {
                successfulRequestBlock(data)
            }
            else if let error = error
            {
                failureRequestBlock(error)
            }
        }
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
