//
//  ChatsViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ChatsViewController: MainViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    var tableView: UITableView!
    var noConversationsLabel: UILabel!
    
    private var conversations = [Conversation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       
        setNavigationItem()
        buildViews()
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
        fetchConversations()
        startListeningForConversations()
        
        tableView = UITableView()
        tableView.isHidden = false
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
    }
    
    func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        DatabaseManager.shared.getAllConvos(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get conversations: \(error)")
            }
        })
    }
    
    @objc func newConvoSearchTapped() {
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            self?.createNewConvo(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func createNewConvo(result: [String: String]) {
        guard let username = result["username"], let email = result["email"] else {
            return
        }
        let vc = ConversationViewController(with: email, id: nil)
        vc.isNewConvo = true
        vc.title = username
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.id)
    }
    
    func fetchConversations() {
        
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
        
        let vc = ConversationViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
//        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
