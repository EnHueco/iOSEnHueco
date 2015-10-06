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
    let sharedManager = SynchronizationManager()
    
    /**
        FIFO queue containing pending requests that failed because of a network error.
    
        - request: NSURLRequest that was attempted
        
        - successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
        - failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
        - associatedObject: Object associated with the request (For example, the Gap that was going to be updated).
    */
    private var pendingRequestsQueue = [(request: NSURLRequest, successfulRequestBlock:ConnectionManagerSuccessfulRequestBlock, failureRequestBlock:ConnectionManagerFailureRequestBlock, associatedObject: EHSynchronizable)]()

    private func addFailedRequestToQueue(request request: NSURLRequest, successfulRequestBlock:ConnectionManagerSuccessfulRequestBlock, failureRequestBlock:ConnectionManagerFailureRequestBlock, associatedObject: EHSynchronizable)
    {
        pendingRequestsQueue.append((request: request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject))
    }
    
    func retryPendingRequests()
    {
        // TODO:
    }
    
    /**
        Tries the given request and adds the request to the queue in case it fails.
    
        - parameter request: NSURLRequest that was attempted
    
        - parameter successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
        - parameter failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
        - parameter associatedObject: Object associated with the request (For example, the Gap that was going to be updated).
    */
    func trySendingAsyncRequestToURL(URL: NSURL, usingMethod method:HTTPMethod, withJSONParams params:Dictionary<String, AnyObject>?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock, associatedObject:EHSynchronizable)
    {
        let synchronizationFailureRequestBlock = {(error: ConnectionManagerError) -> () in
            
            failureRequestBlock(error: ConnectionManagerError(error:error.error, request:error.request))
            
            self.addFailedRequestToQueue(request: error.request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject)
        }
        
        ConnectionManager.sendAsyncRequestToURL(URL, usingMethod: method, withJSONParams: params, onSuccess: successfulRequestBlock, onFailure: synchronizationFailureRequestBlock)
    }
    
    
    /*/**
        Tries the given request and adds the request to the queue in case it fails.
    
        - parameter request: NSURLRequest that was attempted
    
        - parameter successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
        - parameter failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
        - parameter associatedObject: Object associated with the request (For example, the Gap that was going to be updated).
    */
    func trySendingSyncRequestToURL(URL: NSURL, usingMethod method:HTTPMethod, withJSONParams params:Dictionary<String, AnyObject>?, associatedObject:EHSynchronizable) throws -> Dictionary<String, AnyObject>?
    {
        do
        {
            return try ConnectionManager.sendSyncRequestToURL(URL, usingMethod: method, withJSONParams: params)
        }
        catch let error as ConnectionManagerError
        {
            addFailedRequestToQueue(request: error.request, successfulRequestBlock: , failureRequestBlock: <#T##ConnectionManagerFailureRequestBlock##ConnectionManagerFailureRequestBlock##(error: ConnectionManagerError) -> ()#>, associatedObject: <#T##EHSynchronizable#>)
        }
        
        return nil
    }*/
}
