//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

enum HTTPMethod: String
{
    case GET="GET", POST="POST"
}

class HTTPRequestResponseManager: NSObject
{
    class func sendAsyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:Dictionary<String, AnyObject>?,  onSuccess successfulRequestBlock:(Dictionary<String, AnyObject>)->(), onFailure failureRequestBlock:(ErrorType)->() )
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response, data, error) -> Void in
            
            if let data = data where error == nil
            {
                do
                {
                    let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    
                    successfulRequestBlock(JSONResponse as! Dictionary<String, AnyObject>)
                }
                catch
                {
                    failureRequestBlock(error)
                }
            }
            else if let error = error
            {
                failureRequestBlock(error)
            }
        }
    }
    
    class func sendSyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:Dictionary<String, AnyObject>?) throws -> Dictionary<String, AnyObject>
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
        
        let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)

        return JSONResponse as! Dictionary<String, AnyObject>
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
