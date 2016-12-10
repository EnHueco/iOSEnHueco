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
    func firebaseUser(_ errorHandler: @escaping BasicCompletionHandler) -> FIRUser?
}

extension FirebaseLogicManager {
    
    func firebaseUser(_ errorHandler: @escaping BasicCompletionHandler) -> FIRUser? {
        
        guard let user = FIRAuth.auth()?.currentUser else {
            assertionFailure()
            DispatchQueue.main.async{ errorHandler(GenericError.notLoggedIn) }
            return nil
        }
        
        return user
    }
}
