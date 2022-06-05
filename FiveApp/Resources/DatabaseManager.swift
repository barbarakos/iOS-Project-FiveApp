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
    
    static func safeEmail(email: String) -> String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }

}

extension DatabaseManager {
    
    public func createUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "username": user.username,
            "admin": user.admin
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var users = snapshot.value as? [[String: String]] {
                    let elem = [
                        "username": user.username,
                        "email": user.safeEmail
                    ]
                    users.append(elem)
                    self.database.child("users").setValue(users, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                } else {
                    let newUsers: [[String: String]] = [
                        [
                            "username": user.username,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newUsers, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            completion(true)
        })
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
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]],Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}

extension DatabaseManager {
    
    public func createNewConvo(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> (Void)) {
        
    }
    
    public func getAllConvos(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    public func getAllMessagesForConvo(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> (Void)) {
        
    }
    
}

struct AppUser {
    let username: String
    let email: String
    let admin: Bool
    
    var profilePicFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
}
