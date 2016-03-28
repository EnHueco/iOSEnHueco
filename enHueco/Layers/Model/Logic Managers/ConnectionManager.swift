//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_Synchronous

/// HTTP Methods
enum HTTPMethod: String
{
    case GET="GET", POST="POST", DELETE="DELETE"
}

/** An error which contains the error that occurred, along with the request
that triggered it */
struct ConnectionManagerCompoundError: ErrorType
{
    var error: ErrorType?
    var response: NSURLResponse?
    var request: NSMutableURLRequest
}

typealias ConnectionManagerSuccessfulRequestBlock = (JSONResponse: AnyObject) -> ()
typealias ConnectionManagerSuccessfulDataRequestBlock = (data: NSData) -> ()
typealias ConnectionManagerFailureRequestBlock = (compoundError: ConnectionManagerCompoundError) -> ()

struct ConnectionManagerNotifications
{
    /// Thrown when the session expired
    static let sessionDidExpire = "sessionDidExpire"
}

/// Handles all generic network-related operations. **All** network operations should be executed using this manager.
class ConnectionManager: NSObject
{
    static let completionQueue: NSOperationQueue =
    {
        let queue = NSOperationQueue()
        queue.qualityOfService = .Default
        return queue
    }()

    private static let alamoManager: Alamofire.Manager =
    {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [EHURLS.Domain: .DisableEvaluation]
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    
    class func sendAsyncRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]?, onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        
        if params != nil
        {
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.HTTPBody = dictionaryJSONData
        }
        
        sendAsyncRequest(request, onSuccess: successfulRequestBlock, onFailure: failureRequestBlock)
    }
    
    class func sendAsyncDataRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]? = nil, onSuccess successfulRequestBlock: ConnectionManagerSuccessfulDataRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        
        if params != nil
        {
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.HTTPBody = dictionaryJSONData
        }
        
        var request = request
        adjustRequestForBackend(&request)
        
        let alamoRequest = alamoManager.request(request)
        
        alamoRequest.response { (_, response, data, error) -> Void in
            
            completionQueue.addOperationWithBlock
            {
                #if DEBUG
                    debugPrint(alamoRequest); debugPrint(response)
                #endif
                
                let errorHandler =
                {
                    #if DEBUG
                        if let data = data { print(NSString(data: data, encoding: NSUTF8StringEncoding)!) }
                    #endif
                    
                    failureRequestBlock?(compoundError: ConnectionManagerCompoundError(error:error, response: response, request:request))
                }
                
                guard let urlResponse = response where !(urlResponse.statusCode == 401) else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName(ConnectionManagerNotifications.sessionDidExpire, object: self)
                    }
                    
                    errorHandler()
                    return
                }
                
                guard let data = data where error == nil && response?.statusCode == 200 else
                {
                    errorHandler()
                    return
                }
                
                successfulRequestBlock?(data: data)
            }
        }
    }
    
    class func sendAsyncRequest(request: NSMutableURLRequest,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        var request = request
        adjustRequestForBackend(&request)
        
        let alamoRequest = alamoManager.request(request)
        
        alamoRequest.responseJSON(options: .MutableContainers) { (response) -> Void in
            
            completionQueue.addOperationWithBlock
            {
                #if DEBUG
                    debugPrint(alamoRequest); debugPrint(response)
                #endif
                
                let errorHandler = {
                    
                    #if DEBUG
                        if let data = response.data { print(NSString(data: data, encoding: NSUTF8StringEncoding)!) }
                    #endif
                    
                    failureRequestBlock?(compoundError: ConnectionManagerCompoundError(error:response.result.error, response: response.response, request:request))
                    return
                }
                
                guard let urlResponse = response.response where !(urlResponse.statusCode == 401) else
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName(ConnectionManagerNotifications.sessionDidExpire, object: self)
                    }
                    
                    errorHandler()
                    return
                }
                
                guard let value = response.result.value where response.result.isSuccess && response.response?.statusCode == 200 else
                {
                    errorHandler()
                    return
                }
                
                successfulRequestBlock?(JSONResponse: value)
            }
        }
    }
    
    private class func adjustRequestForBackend(inout request: NSMutableURLRequest)
    {
        guard let appUser = enHueco.appUser else { return }
        
        if let url = request.URL where url.absoluteString.hasPrefix(EHURLS.Base)
        {
            request.setValue(appUser.username, forHTTPHeaderField: EHParameters.UserID)
            request.setValue(appUser.token, forHTTPHeaderField: EHParameters.Token)
        }
    }
    
    class func sendSyncRequest(request: NSMutableURLRequest) throws -> AnyObject
    {
        let semaphore = dispatch_semaphore_create(0)
        
        sendAsyncRequest(request, onSuccess: { (JSONResponse) in
            
            dispatch_semaphore_signal(semaphore)
            
            
            
        }) { (compoundError) in
            
            
        }

//        while dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) {
//            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())
//        }
//
//        let response = alamoManager.request(request).responseJSON(options: .MutableContainers)
//        
//        if let error = response.result.error { throw error }
//        
//        return response.result.value ?? [:]
        
        return [:]
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
