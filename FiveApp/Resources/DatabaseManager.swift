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
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        
        let reference = database.child("\(safeEmail)")
        
        reference.observeSingleEvent(of: .value, with: { snapshot in
            guard var user = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            let massageDate = firstMessage.sentDate
            let dateString = ConversationViewController.dateFormatter.string(from: massageDate)
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConvoData: [String: Any] = [
                "id": conversationId,
                "otherUserEmail": otherUserEmail,
                "latestMessage": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                ]
            ]
            
            if var conversations = user["conversations"] as? [[String: Any]] {
                //conversation exists for current user, should append
                conversations.append(newConvoData)
                user["conversations"] = conversations
                
                reference.setValue(user, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishConvoCreating(conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
                
            } else {
                //conversation array doenst exist, should create it
                user["conversations"] = [
                    newConvoData
                ]
                
                reference.setValue(user, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishConvoCreating(conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    func finishConvoCreating(conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        var content = ""
        switch firstMessage.kind {
        case .text(let messageText):
            content = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let massageDate = firstMessage.sentDate
        let dateString = ConversationViewController.dateFormatter.string(from: massageDate)
        
        guard let em = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(email: em)
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.description,
            "content": content,
            "date": dateString,
            "senderEmail": currentUserEmail,
            "isRead": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        
        database.child("\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
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
