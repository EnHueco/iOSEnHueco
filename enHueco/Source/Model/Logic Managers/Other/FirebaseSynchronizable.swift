//
//  FirebaseSynchronizable.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/23/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

class FirebaseSynchronizable {
    
    let appUserID: String
    
    /// All references and handles for the references
    private var databaseRefsAndHandles = [FIRDatabaseReference : [FIRDatabaseHandle]]()
    
    /** Creates an instance of the manager that listens to database changes as soon as it is created.
     You must set the delegate property if you want to be notified when any data has changed.
     */
    init?() {
        guard let userID = AccountManager.sharedManager.userID else {
            assertionFailure()
            return nil
        }
        
        appUserID = userID
        _createFirebaseSubscriptions()
    }
    
    func _createFirebaseSubscriptions() {
        fatalError("Not yet implemented")
    }
    
    func _trackHandle(handle: FIRDatabaseHandle, forReference reference: FIRDatabaseReference) {
        
        if databaseRefsAndHandles[reference] == nil {
            databaseRefsAndHandles[reference] = []
        }
        
        databaseRefsAndHandles[reference]?.append(handle)
    }
    
    private func removeFirebaseSubscriptions() {
        
        for (reference, handles) in databaseRefsAndHandles {
            for handle in handles {
                reference.removeObserverWithHandle(handle)
            }
        }
        
        databaseRefsAndHandles = [:]
    }
    
    deinit {
        removeFirebaseSubscriptions()
    }
}