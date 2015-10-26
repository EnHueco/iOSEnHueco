//
//  SynchronizationManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class SynchronizationManager: NSObject
{
    static private var instance = SynchronizationManager()
    
    /**
        FIFO queue containing pending requests that failed because of a network error.
    
        - request: NSURLRequest that was attempted
        
        - successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
        - failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
        - associatedObject: Object associated with the request (For example, the Gap that was going to be updated).
    */
    private var pendingRequestsQueue = [(request: NSURLRequest, successfulRequestBlock:ConnectionManagerSuccessfulRequestBlock?, failureRequestBlock:ConnectionManagerFailureRequestBlock?, associatedObject: EHSynchronizable)]()
    
    let retryQueue = NSOperationQueue()
    
    override init()
    {
        retryQueue.maxConcurrentOperationCount = 1
        retryQueue.qualityOfService = .Background
        
        super.init()
    }
    
    static func sharedManager() -> SynchronizationManager
    {
        return instance
    }
    
    // MARK: Synchronization

    private func addFailedRequestToQueue(request request: NSURLRequest, successfulRequestBlock:ConnectionManagerSuccessfulRequestBlock?, failureRequestBlock:ConnectionManagerFailureRequestBlock?, associatedObject: EHSynchronizable)
    {
        pendingRequestsQueue.append((request: request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject))
    }
    
    /**
    Attempts to retry every request in the pending requests queue in order.
      
    If every request could be executed successfully the queue is emptied, if
    any request fails the queue is emptied only partially.
    */
    func retryPendingRequests()
    {
        retryQueue.addOperationWithBlock()
        {
            while self.trySendingNextSyncRequestInQueue() {}
        }
    }
    
    
    /**
     Tries the given request and adds the request to the queue in case it fails.
     */
    private func trySendingNextSyncRequestInQueue() -> Bool
    {
        guard let (request, successfulRequestBlock, failureRequestBlock, associatedObject) = pendingRequestsQueue.first else { return false }
        
        do
        {
            let responseDictionary = try ConnectionManager.sendSyncRequest(request)!
            
            pendingRequestsQueue.removeFirst()
            
            let serverLastUpdatedOn = NSDate(serverFormattedString: responseDictionary["lastUpdatedOn"] as! String)!
            
            if serverLastUpdatedOn < associatedObject.lastUpdatedOn { return true }
            
            successfulRequestBlock?(JSONResponse: responseDictionary)
            return true
        }
        catch
        {
            failureRequestBlock?(error: ConnectionManagerCompoundError(error:error, request:request))
            
            return false
        }
    }
    
    // MARK: Requests
    
    /**
        Tries the given request and adds the request to the queue in case it fails.
    
        - parameter request: NSURLRequest that was attempted
    
        - parameter successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
        - parameter failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
        - parameter associatedObject: Object associated with the request (For example, the Gap that was going to be updated).
    */
    func sendAsyncRequestToURL(URL: NSURL, usingMethod method:HTTPMethod, withJSONParams params:[String : AnyObject]?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock?, associatedObject:EHSynchronizable)
    {
        let synchronizationFailureRequestBlock = {(error: ConnectionManagerCompoundError) -> () in
            
            failureRequestBlock?(error: ConnectionManagerCompoundError(error:error.error, request:error.request))
            
            self.addFailedRequestToQueue(request: error.request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject)
        }
        
        ConnectionManager.sendAsyncRequestToURL(URL, usingMethod: method, withJSONParams: params, onSuccess: successfulRequestBlock, onFailure: synchronizationFailureRequestBlock)
    }
    
    /**
    Tries the given request and adds the request to the queue in case it fails.
    
    - parameter request: NSURLRequest that was attempted
    
    - parameter successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
    - parameter failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
    - parameter associatedObject: Object associated with the request (For example, the Gap that was going to be updated).
    */
    func sendAsyncRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock?, associatedObject:EHSynchronizable)
    {
        let synchronizationFailureRequestBlock = {(error: ConnectionManagerCompoundError) -> () in
            
            failureRequestBlock?(error: ConnectionManagerCompoundError(error:error.error, request:error.request))
            
            self.addFailedRequestToQueue(request: error.request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject)
        }
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, onSuccess: successfulRequestBlock, onFailure: synchronizationFailureRequestBlock)
    }
    
    // MARK: Reporting
    
    func reportNewEvent(newEvent: Event)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.EventsSegment)!)
        request.setValue(system.appUser.username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(system.appUser.token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "POST"
        
        var params = newEvent.toJSONObject()
        params["user"] = system.appUser.username
        
        sendAsyncRequest(request, withJSONParams: params, onSuccess: nil, onFailure: nil, associatedObject: system.appUser)
        
        //TODO: Change associated object
    }
}
