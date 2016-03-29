//
//  SynchronizationManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

/**
 Handles  synchronization with the server of data that we must ensure is uplodaded when a connection is available in case the upload fails.
 
 The Synchronization Manager maintains a persistent queue to guarantee that operations are executed in order
 and when a connection is available.
*/
class SynchronizationManager: NSObject, NSCoding
{
    // TODO: Should be a struct but NSCoding doesn't let us.
    class PendingRequest: NSObject, NSCoding
    {
        /// NSURLRequest that was attempted
        let request: NSMutableURLRequest
        
        /// Closure to be executed in case of success when reattempting the request.
        let successfulRequestBlock:ConnectionManagerSuccessfulRequestBlock?
        
        /// Closure to be executed in case of an error when reattempting the request
        let failureRequestBlock:ConnectionManagerFailureRequestBlock?
        
        /// Object associated with the request (For example, the Free time period that was going to be updated).
        let associatedObject: EHSynchronizable
        
        init(request: NSMutableURLRequest, successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, failureRequestBlock: ConnectionManagerFailureRequestBlock?, associatedObject: EHSynchronizable) {
            self.request = request
            self.successfulRequestBlock = successfulRequestBlock
            self.failureRequestBlock = failureRequestBlock
            self.associatedObject = associatedObject
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            self.successfulRequestBlock = nil
            self.failureRequestBlock = nil

            guard let request = aDecoder.decodeObjectForKey("request") as? NSMutableURLRequest,
                  let associatedObject = aDecoder.decodeObjectForKey("associatedObject") as? EHSynchronizable
            else
            {
                self.request = NSMutableURLRequest()
                self.associatedObject = EHSynchronizable(ID: nil, lastUpdatedOn: NSDate())
                
                super.init()
                return nil
            }
            
            self.request = request
            self.associatedObject = associatedObject
            
            super.init()
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            
            aCoder.encodeObject(request, forKey: "request")
            aCoder.encodeObject(associatedObject, forKey: "associatedObject")
        }
    }
    
    /// Path where data will be persisted
    private static let persistencePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/synchronizationManager.state"

    private static var instance: SynchronizationManager?
    
    /**
        FIFO queue containing pending requests that failed because of a network error.
    */
    private var pendingRequestsQueue = [PendingRequest]()
    
    let retryQueue = NSOperationQueue()
    
    private override init()
    {
        retryQueue.maxConcurrentOperationCount = 1
        retryQueue.qualityOfService = .Background        
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard let pendingRequestsQueue = decoder.decodeObjectForKey("pendingRequestsQueue") as? [PendingRequest] else
        {
            super.init()
            return nil
        }
        
        self.pendingRequestsQueue = pendingRequestsQueue
        
        super.init()
    }
    
    class func sharedManager() -> SynchronizationManager
    {
        if instance == nil
        {
            instance = managerFromPersistence() ?? SynchronizationManager()
        }
        
        return instance!
    }
    
    /// Tries to initialize a SynchronizationManager instance from persistence
    private static func managerFromPersistence () -> SynchronizationManager?
    {
        let manager = NSKeyedUnarchiver.unarchiveObjectWithFile(persistencePath) as? SynchronizationManager
    
        if manager == nil
        {
            try? NSFileManager.defaultManager().removeItemAtPath(persistencePath)
        }
     
        return manager
    }
    
    func persistData() -> Bool
    {
        return NSKeyedArchiver.archiveRootObject(self, toFile: SynchronizationManager.persistencePath)
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(pendingRequestsQueue, forKey: "pendingRequestsQueue")
    }
    
    // MARK: Synchronization

    private func addPendingRequestToQueue(request request: NSMutableURLRequest, successfulRequestBlock:ConnectionManagerSuccessfulRequestBlock?, failureRequestBlock:ConnectionManagerFailureRequestBlock?, associatedObject: EHSynchronizable)
    {
        pendingRequestsQueue.append(PendingRequest(request: request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject))
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
        guard let pendingRequest = pendingRequestsQueue.first else { return false }
        
        do
        {
            let responseDictionary = try ConnectionManager.sendSyncRequest(pendingRequest.request)
            
            pendingRequestsQueue.removeFirst()
                        
            pendingRequest.successfulRequestBlock?(JSONResponse: responseDictionary)
            return true
        }
        catch
        {
            pendingRequest.failureRequestBlock?(compoundError: ConnectionManagerCompoundError(error: error, response: nil, request:pendingRequest.request))
            return false
        }
    }
    
    // MARK: Requests
    
    /**
    Tries the given request and adds the request to the queue in case it fails.
    
    - parameter request: NSURLRequest that was attempted
    
    - parameter successfulRequestBlock: Closure to be executed in case of success when reattempting the request.
    - parameter failureRequestBlock: Closure to be executed in case of an error when reattempting the request.
    - parameter associatedObject: Object associated with the request (For example, the free time period that was going to be updated).
    */
    func sendAsyncRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]?,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock?, associatedObject:EHSynchronizable)
    {
        //TODO: DELETE THIS !
        pendingRequestsQueue = []
        
        let synchronizationFailureRequestBlock = {(error: ConnectionManagerCompoundError) -> () in
            
            failureRequestBlock?(compoundError: ConnectionManagerCompoundError(error:error.error, response: error.response, request:error.request))
            
            self.addPendingRequestToQueue(request: error.request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject)
        }
        
        guard pendingRequestsQueue.isEmpty else
        {
            addPendingRequestToQueue(request: request, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: failureRequestBlock, associatedObject: associatedObject)
            retryPendingRequests()
            
            return
        }
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, onSuccess: successfulRequestBlock, onFailure: synchronizationFailureRequestBlock)
    }
    
    // MARK: Reporting
    
    ///Reports to the server a new event added
    func reportNewEvent(newEvent: Event)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.EventsSegment)!)
        request.HTTPMethod = "POST"
        
        let params = newEvent.toJSONObject(associatingUser: enHueco.appUser)
        
        sendAsyncRequest(request, withJSONParams: params, onSuccess: { (JSONResponse) -> () in
            
            let JSONDictionary = (JSONResponse as! [String : AnyObject])
            newEvent.ID = "\(JSONDictionary["id"] as! Int)"
            newEvent.lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
            print("Reported new event")
            
        }, onFailure: nil, associatedObject: enHueco.appUser)
    
        //TODO: Change associated object
    }
    
    ///Reports to the server an edit to an event
    func reportEventEdited(event: Event)
    {
        guard let ID = event.ID else { /* Throw error ? */ return }
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.EventsSegment + ID + "/")!)
        request.HTTPMethod = "PUT"

        sendAsyncRequest(request, withJSONParams: event.toJSONObject(associatingUser: enHueco.appUser), onSuccess: { (JSONResponse) -> () in
            
            let JSONDictionary = JSONResponse as! [String : AnyObject]
            event.lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
            print("Reported event edited")

        }, onFailure: nil, associatedObject: enHueco.appUser)
    }
    
    ///Reports to the server a deleted evet
    func reportEventDeleted(event: Event)
    {
        guard let ID = event.ID else { /* Throw error ? */ return }
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.EventsSegment + ID + "/")!)
        request.HTTPMethod = "DELETE"

        sendAsyncRequest(request, withJSONParams: nil, onSuccess: { (JSONResponse) -> () in
            
            print("Reported event deleted")
            
        }, onFailure: nil, associatedObject: enHueco.appUser)
    }    
}

