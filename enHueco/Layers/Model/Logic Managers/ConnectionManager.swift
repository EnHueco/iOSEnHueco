//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Alamofire

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
    /** Debug flag. If true ConnectionManager will print a lot of useful information to the console.
     True by default if a compiler flag "DEBUG" is found, false by default otherwise.
     */
    static var debug = { () -> Bool in
        
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
    
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
    
    class func sendAsyncRequest(request: NSMutableURLRequest, withJSONParams params: AnyObject?, successCompletionHandler: ConnectionManagerSuccessfulRequestBlock?, failureCompletionHandler: ConnectionManagerFailureRequestBlock? )
    {
        do
        {
            var request = request
            try addJSONParameters(params, toRequest: &request)
            
            sendAsyncRequest(request, successCompletionHandler: successCompletionHandler, failureCompletionHandler: failureCompletionHandler)
        }
        catch
        {
            failureCompletionHandler?(compoundError: ConnectionManagerCompoundError(error: error, response: nil))
        }
    }
    
    class func sendAsyncDataRequest(request: NSMutableURLRequest, withJSONParams params: AnyObject? = nil, successCompletionHandler: ConnectionManagerSuccessfulDataRequestBlock?, failureCompletionHandler: ConnectionManagerFailureRequestBlock? )
    {
        do
        {
            var request = request
            try addJSONParameters(params, toRequest: &request)
            addSessionHeadersToRequest(&request)
            
            let alamoRequest = alamoManager.request(request)
            
            alamoRequest.responseData(completionHandler: { (response) in
                
                completionQueue.addOperationWithBlock {
                    
                    _processResponse(response, forRequest: alamoRequest, successCompletionHandler: successCompletionHandler, failureCompletionHandler: failureCompletionHandler)
                }
            })
        }
        catch
        {
            failureCompletionHandler?(compoundError: ConnectionManagerCompoundError(error: error, response: nil))
        }
    }
    
    class func sendAsyncRequest(request: NSMutableURLRequest,  successCompletionHandler: ConnectionManagerSuccessfulRequestBlock?, failureCompletionHandler: ConnectionManagerFailureRequestBlock? )
    {
        var request = request
        addSessionHeadersToRequest(&request)
        
        let alamoRequest = alamoManager.request(request)
        
        alamoRequest.responseJSON(options: .MutableContainers) { (response) -> Void in
            
            completionQueue.addOperationWithBlock {
                
                _processResponse(response, forRequest: alamoRequest, successCompletionHandler: successCompletionHandler, failureCompletionHandler: failureCompletionHandler)
            }
        }
    }
    
    private class func _processResponse<ValueType>(response: Response<ValueType, NSError>, forRequest request: Request,
                                        successCompletionHandler: ((value: ValueType) -> Void)?, failureCompletionHandler: ConnectionManagerFailureRequestBlock?) {
        
        if debug {
            debugPrint(request); debugPrint(response)
        }
        
        let errorHandler = {
            
            if let data = response.data where debug {
                print(NSString(data: data, encoding: NSUTF8StringEncoding)!)
            }
            
            failureCompletionHandler?(compoundError: ConnectionManagerCompoundError(error:response.result.error, response: response.response))
            return
        }
        
        guard response.response?.statusCode != 401 else {
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(ConnectionManagerNotifications.sessionDidExpire, object: self)
            }
            
            errorHandler()
            return
        }
        
        guard let value = response.result.value where response.result.isSuccess else {
            errorHandler()
            return
        }
        
        successCompletionHandler?(value: value)
    }
    
    private class func addJSONParameters(params: AnyObject?, inout toRequest request: NSMutableURLRequest) throws
    {
        if let dictionaryJSONData:NSData? = params != nil ? try NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil {
            
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.HTTPBody = dictionaryJSONData
        }
    }
    
    private class func addSessionHeadersToRequest(inout request: NSMutableURLRequest)
    {
        guard let appUser = enHueco.appUser else { return }
        
        if let url = request.URL where url.absoluteString.hasPrefix(EHURLS.Base)
        {
            request.setValue(appUser.username, forHTTPHeaderField: EHParameters.UserID)
            request.setValue(NSUserDefaults.standardUserDefaults().objectForKey("token") as? String, forHTTPHeaderField: EHParameters.Token)
        }
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
