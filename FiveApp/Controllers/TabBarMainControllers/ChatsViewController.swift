//
//  ChatsViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class ChatsViewController: MainViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    var tableView: UITableView!
    var noConversationsLabel: UILabel!
    
    private var loginObserver: NSObjectProtocol?
    
    private var conversations = [Conversation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       
        setNavigationItem()
        buildViews()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForConversations()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateUser()
    }

    func validateUser() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LogInViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    func setNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newConvoSearchTapped))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func buildViews() {
        createViews()
        styleViews()
        defineLayoutForViews()
    }
    
    func createViews() {
        startListeningForConversations()
        
        tableView = UITableView()
        tableView.isHidden = true
        configureTableView()
        view.addSubview(tableView)
        
        noConversationsLabel = UILabel()
        noConversationsLabel.isHidden = true
        view.addSubview(noConversationsLabel)
    }
    
    func styleViews() {
        noConversationsLabel.text = "No Conversations"
        noConversationsLabel.textColor = .gray
        noConversationsLabel.textAlignment = .center
        noConversationsLabel.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
    }
    
    func defineLayoutForViews() {
        tableView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        noConversationsLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.center.equalToSuperview()
        }
    }
    
    func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        DatabaseManager.shared.getAllConvos(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.noConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("Failed to get conversations: \(error)")
            }
        })
    }
    
    @objc func newConvoSearchTapped() {
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            //check if conversation exists
            let currentConversations = strongSelf.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(email: result.email)
            }) {
                let vc = ConversationViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConvo = false
                vc.title = targetConversation.name
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            } else {
                //if conversation doesnt exist
                strongSelf.createNewConvo(result: result)
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func createNewConvo(result: SearchResult) {
        let username = result.username
        let email = DatabaseManager.safeEmail(email: result.email)
        
        //check in database if conversation with these users exists
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let conversationId):
                let vc = ConversationViewController(with: email, id: conversationId)
                vc.isNewConvo = false
                vc.title = username
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ConversationViewController(with: email, id: nil)
                vc.isNewConvo = true
                vc.title = username
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.id)
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatsTableViewCell.id, for: indexPath) as! ChatsTableViewCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ConversationViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let conversationId = conversations[indexPath.row].id
            conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                    print("failed to delete")
                }
            })
            tableView.endUpdates()
        }
    }
}

