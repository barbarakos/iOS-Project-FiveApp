//
//  ConversationViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 31.05.2022..
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class ConversationViewController: MessagesViewController {
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConvo = false
    private var conversationId: String?
    public let otherUserEmail: String!
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        conversationId = id
        otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        setNavigationItem()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let convId = conversationId {
            listenForMessages(id: convId)
        }
    }
    
    
    func configure() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        //messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
    }
    
    func setNavigationItem() {
        
    }
    
    func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConvo(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        })
    }

}

extension ConversationViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender, let messageId = createMessageId() else {
            return
        }
        
        print("sending")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        //send message
        if isNewConvo {
            DatabaseManager.shared.createNewConvo(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.messageInputBar.inputTextView.text = nil
                    self?.isNewConvo = false
                    let newConversationId = "conversation_\(messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId)
                } else {
                    print("failed to send")
                }
            })
        } else {
            //append to existing convo
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, message: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("failed to send")
                }
            })
        }
    }
    
    func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCurrUserEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date()).replacingOccurrences(of: "/", with: "-")
        let newId = "\(otherUserEmail!)_\(safeCurrUserEmail)_\(dateString)"
        return newId
    }
}

extension ConversationViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            //our message
            return UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.8)
        }
        //received message
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            //show our image
            if let currentUserImageURL = senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL)
            } else {
                //fetch URL - path: "images/safeEmail_profile_picture.png"
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeEmail = DatabaseManager.safeEmail(email: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                    
                })
            }
        } else {
            //show other user image
            if let otherUserImageURL = otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserImageURL)
            } else {
                //fetch URL - path: "images/safeEmail_profile_picture.png"
                let otheremail = self.otherUserEmail
                
                let safeEmail = DatabaseManager.safeEmail(email: otheremail!)
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                    
                })
            }
        }
    }
}


