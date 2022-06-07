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
    
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
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
    
    public func createNewConvo(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> (Void)) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let username = UserDefaults.standard.value(forKey: "username") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        
        let reference = database.child("\(safeEmail)")
        
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var user = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            let massageDate = firstMessage.sentDate
            let dateString = ConversationViewController.dateFormatter.string(from: massageDate).replacingOccurrences(of: "/", with: "-")
            print(dateString)
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
                "name": name,
                "latestMessage": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                ]
            ]
            
            let otherUser_newConvoData: [String: Any] = [
                "id": conversationId,
                "otherUserEmail": safeEmail,
                "name": username,
                "latestMessage": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                ]
            ]
            
            //other user conversations update
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(otherUser_newConvoData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                } else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([otherUser_newConvoData])
                }
            })
            
            
            
            //current user conversations update
            if var conversations = user["conversations"] as? [[String: Any]] {
                //conversation exists for current user, should append
                conversations.append(newConvoData)
                user["conversations"] = conversations
                
                reference.setValue(user, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishConvoCreating(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
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
                    
                    self?.finishConvoCreating(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    func finishConvoCreating(name: String, conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
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
        let dateString = ConversationViewController.dateFormatter.string(from: massageDate).replacingOccurrences(of: "/", with: "-")
        
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
            "isRead": false,
            "name": name
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
    
    public func getAllConvos(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["otherUserEmail"] as? String,
                      let latestMessage = dictionary["latestMessage"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool else {
                    return nil
                }
                
                let lastMessage = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: lastMessage)
            })
            completion(.success(conversations))
        })
    }
    
    public func getAllMessagesForConvo(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["senderEmail"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ConversationViewController.dateFormatter.date(from: dateString) else {
                    return nil
                }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
            })
            
            completion(.success(messages))
        })
    }
    
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, message: Message, completion: @escaping (Bool) -> (Void)) {
        guard let myemail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentEmail = DatabaseManager.safeEmail(email: myemail)
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            var content = ""
            switch message.kind {
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
            
            let massageDate = message.sentDate
            let dateString = ConversationViewController.dateFormatter.string(from: massageDate).replacingOccurrences(of: "/", with: "-")
            
            guard let em = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            let currentUserEmail = DatabaseManager.safeEmail(email: em)
            
            let newMessage: [String: Any] = [
                "id": message.messageId,
                "type": message.kind.description,
                "content": content,
                "date": dateString,
                "senderEmail": currentUserEmail,
                "isRead": false,
                "name": name
            ]
            
            currentMessages.append(newMessage)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "message": content,
                        "isRead": false
                    ]
                    
                    var targetConv: [String: Any]?
                    
                    var position = 0
                    
                    for currentconversation in currentUserConversations {
                        if let currentId = currentconversation["id"] as? String, currentId == conversation {
                            targetConv = currentconversation
                            break
                        }
                        position += 1
                    }
                    targetConv?["latestMessage"] = updatedValue
                    guard let targetConv = targetConv else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = targetConv
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //update latest message for other user
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "message": content,
                                "isRead": false
                            ]
                            
                            var targetConv: [String: Any]?
                            
                            var position = 0
                            
                            for currentconversation in otherUserConversations {
                                if let currentId = currentconversation["id"] as? String, currentId == conversation {
                                    targetConv = currentconversation
                                    break
                                }
                                position += 1
                            }
                            targetConv?["latestMessage"] = updatedValue
                            guard let targetConv = targetConv else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = targetConv
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
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
