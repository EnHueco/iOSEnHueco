//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Alamofire

enum HTTPMethod: String
{
    case GET="GET", POST="POST"
}

struct ConnectionManagerCompoundError: ErrorType
{
    var error: ErrorType
    var request: NSURLRequest
}

typealias ConnectionManagerSuccessfulRequestBlock = (JSONResponse: AnyObject) -> ()
typealias ConnectionManagerFailureRequestBlock = (error: ConnectionManagerCompoundError) -> ()

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
    
    class func sendAsyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:[String : AnyObject]?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock?)
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        sendAsyncRequest(request, onSuccess: successfulRequestBlock, onFailure: failureRequestBlock)
    }
    
    class func sendAsyncRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]?, onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        sendAsyncRequest(request, onSuccess: successfulRequestBlock, onFailure: failureRequestBlock)
    }
    
    class func sendSyncRequestToURL(url: NSURL, usingMethod method:HTTPMethod, withJSONParams params:[String : AnyObject]?) throws -> AnyObject?
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod.POST.rawValue
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        return try sendSyncRequest(request)
    }
    
    class func sendAsyncRequest(request: NSURLRequest,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        alamoManager.request(request).response { (_, response, data, error) -> Void in
            
            completionQueue.addOperationWithBlock
            {
                if let data = data where error == nil
                {
                    do
                    {
                        let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                        
                        successfulRequestBlock?(JSONResponse: JSONResponse)
                    }
                    catch
                    {
                        print(NSString(data: data, encoding: NSUTF8StringEncoding))
                        print(error)
                        failureRequestBlock?(error: ConnectionManagerCompoundError(error:error, request:request))
                    }
                }
                else if let error = error
                {
                    print("\(error.code) : \(error)")
                    failureRequestBlock?(error: ConnectionManagerCompoundError(error:error, request:request))
                }
            }
        }
    }
    
    class func sendSyncRequest(request: NSURLRequest) throws -> AnyObject?
    {
        var response: NSURLResponse?
        
        do
        {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            
            let JSONResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            
            return JSONResponse
        }
        catch
        {
            return nil
        }
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
