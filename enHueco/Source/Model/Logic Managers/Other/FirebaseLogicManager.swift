//
//  FirebaseLogicManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/25/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol FirebaseLogicManager {
    func firebaseUser(errorHandler errorHandler: BasicCompletionHandler) -> FIRUser?
}

extension FirebaseLogicManager {
    
    func firebaseUser(errorHandler errorHandler: BasicCompletionHandler) -> FIRUser? {
        
        guard let user = FIRAuth.auth()?.currentUser else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.NotLoggedIn) }
            return nil
        }
        
        return user
    }
}