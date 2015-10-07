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

struct ConnectionManagerCompoundError: ErrorType
{
    var error: ErrorType
    var request: NSURLRequest
}

typealias ConnectionManagerSuccessfulRequestBlock = (JSONResponse: [String : AnyObject]) -> ()
typealias ConnectionManagerFailureRequestBlock = (error: ConnectionManagerCompoundError) -> ()

class ConnectionManager: NSObject
{
    class func sendAsyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:[String : AnyObject]?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock)
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        sendAsyncRequest(request, onSuccess: successfulRequestBlock, onFailure: failureRequestBlock)
    }
    
    class func sendSyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:[String : AnyObject]?) throws -> [String : AnyObject]
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        return try sendSyncRequest(request)
    }
    
    class func sendAsyncRequest(request: NSURLRequest,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock )
    {
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if let data = data where error == nil
            {
                do
                {
                    let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    
                    successfulRequestBlock(JSONResponse: JSONResponse as! [String : AnyObject])
                }
                catch
                {
                    failureRequestBlock(error: ConnectionManagerCompoundError(error:error, request:request))
                }
            }
            else if let error = error
            {
                failureRequestBlock(error: ConnectionManagerCompoundError(error:error, request:request))
            }
        }
    }
    
    class func sendSyncRequest(request: NSURLRequest) throws -> [String : AnyObject]
    {
        var response: NSURLResponse?
        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        
        let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        
        return JSONResponse as! [String : AnyObject]
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
