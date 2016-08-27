//
//  FirebaseSynchronizable.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/23/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseSynchronizable {
    
    init?()
    
    private let firebaseUser: FIRUser
    
    /// All references and handles for the references
    private var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]]
    
    private func createFirebaseSubscriptions()
    
    private func addHandle(handle: FIRDatabaseHandle, toReference reference: FIRDatabaseReference)
}

extension FirebaseSynchronizable {
        
    private func removeFirebaseSubscriptions() {
        
        for (reference, handles) in databaseRefsAndHandles {
            for handlle in handles {
                reference.removeObserverWithHandle(handle)
            }
        }
        
        databaseRefsAndHandles = [:]
    }
    
    private func addHandle(handle: FIRDatabaseHandle, toReference reference: FIRDatabaseReference) {
        
        if databaseRefsAndHandles[reference] == nil {
            databaseRefsAndHandles[reference] = []
        }
        
        databaseRefsAndHandles[reference]?.append(handle)
    }
}