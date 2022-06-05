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
    
    @objc func newConvoSearchTapped() {
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            self?.createNewConvo(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    func createNewConvo(result: [String: String]) {
        guard let username = result["username"], let email = result["email"] else {
            return
        }
        let vc = ConversationViewController(with: email)
        vc.isNewConvo = true
        vc.title = username
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    func fetchConversations() {
        
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = "Hello world"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ConversationViewController(with: "blabla@gmail.com")
        vc.title = "Jenny Smith"
        vc.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"))
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
