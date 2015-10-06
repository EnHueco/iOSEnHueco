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

struct ConnectionManagerError: ErrorType
{
    var error: ErrorType
    var request: NSURLRequest
}

typealias ConnectionManagerSuccessfulRequestBlock = (JSONResponse: Dictionary<String, AnyObject>) -> ()
typealias ConnectionManagerFailureRequestBlock = (error: ConnectionManagerError) -> ()

class ConnectionManager: NSObject
{
    class func sendAsyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:Dictionary<String, AnyObject>?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock)
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if let data = data where error == nil
            {
                do
                {
                    let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    
                    successfulRequestBlock(JSONResponse: JSONResponse as! Dictionary<String, AnyObject>)
                }
                catch
                {
                    failureRequestBlock(error: ConnectionManagerError(error:error, request:request))
                }
            }
            else if let error = error
            {
                failureRequestBlock(error: ConnectionManagerError(error:error, request:request))
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
        
        var response: NSURLResponse?
        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        
        let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)

        return JSONResponse as! Dictionary<String, AnyObject>
    }
    
    class func sendAsyncRequest(request: NSURLRequest,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock )
    {
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if let data = data where error == nil
            {
                do
                {
                    let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    
                    successfulRequestBlock(JSONResponse: JSONResponse as! Dictionary<String, AnyObject>)
                }
                catch
                {
                    failureRequestBlock(error: ConnectionManagerError(error:error, request:request))
                }
            }
            else if let error = error
            {
                failureRequestBlock(error: ConnectionManagerError(error:error, request:request))
            }
        }
    }
    
    class func sendSyncRequest(request: NSURLRequest) throws -> Dictionary<String, AnyObject>
    {
        var response: NSURLResponse?
        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        
        let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        
        return JSONResponse as! Dictionary<String, AnyObject>
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
