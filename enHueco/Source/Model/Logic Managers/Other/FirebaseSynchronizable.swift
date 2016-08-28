//
//  FirebaseSynchronizable.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/23/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseSynchronizable: class {
    
    init?()
    
    var appUserID: String { get }
    
    /// All references and handles for the references
    var databaseRefsAndHandles: [FIRDatabaseReference : [FIRDatabaseHandle]] { get set }
    
    func createFirebaseSubscriptions()
    
    func trackHandle(handle: FIRDatabaseHandle, forReference reference: FIRDatabaseReference)
}

extension FirebaseSynchronizable {
        
    private func removeFirebaseSubscriptions() {
        
        for (reference, handles) in databaseRefsAndHandles {
            for handle in handles {
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