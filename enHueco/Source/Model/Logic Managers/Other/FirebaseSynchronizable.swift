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
    private var databaseRefsAndHandles: [(FIRDatabaseReference, FIRDatabaseHandle)]
    
    private func createFirebaseSubscriptions()
}

extension FirebaseSynchronizable {
        
    private func removeFirebaseSubscriptions() {
        
        while let (ref, handle) = databaseRefsAndHandles.popLast() {
            ref.removeObserverWithHandle(handle)
        }
    }
}