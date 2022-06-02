//
//  DatabaseManager.swift
//  FiveApp
//
//  Created by Barbara Kos on 31.05.2022..
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()

}

extension DatabaseManager {
    
    public func createUser(with user: AppUser) {
        database.child(user.safeEmail).setValue([
            "username": user.username,
            "admin": user.admin
        ])
        
    }
    
    public func userWithEmailExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
}

struct AppUser {
    let username: String
    let email: String
    let admin: Bool
    
    var safeEmail: String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
}
