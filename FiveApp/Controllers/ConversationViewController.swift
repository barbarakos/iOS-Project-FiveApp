//
//  ConversationViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 31.05.2022..
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ConversationViewController: MessagesViewController {
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
        self.conversationId = id
        self.otherUserEmail = email
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
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
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
                    self?.isNewConvo = false
                } else {
                    print("failed to send")
                }
            })
        } else {
            //append to existing convo
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, message: message, completion: { success in
                if success {
                    print("message sent")
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
}

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var description: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}
