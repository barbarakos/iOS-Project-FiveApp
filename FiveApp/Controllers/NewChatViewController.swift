//
//  NewChatViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import JGProgressHUD

final class NewChatViewController: UIViewController {
    public var completion: ((SearchResult) -> (Void))?
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetchedUsers = false
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    var noUsersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildViews()
    }
    
    func buildViews() {
        createViews()
        styleViews()
        defineLayoutForViews()
    }
    
    func createViews() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        
        tableView = UITableView()
        configureTableView()
        view.addSubview(tableView)
        
        noUsersLabel = UILabel()
        noUsersLabel.text = "No Users Found"
        noUsersLabel.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        noUsersLabel.textAlignment = .center
        //noUsersLabel.textColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1)
        noUsersLabel.textColor = .gray
        view.addSubview(noUsersLabel)
    }
    
    func styleViews() {
        searchBar.placeholder = "Search for Users"
        
        tableView.isHidden = true
        
        noUsersLabel.isHidden = true
    }
    
    func defineLayoutForViews() {
        tableView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        noUsersLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(150)
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewChatTableViewCell.self, forCellReuseIdentifier: NewChatTableViewCell.id)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    

}

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewChatTableViewCell.id, for: indexPath) as! NewChatTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(userData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension NewChatViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetchedUsers {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let users):
                    self?.hasFetchedUsers = true
                    self?.users = users
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to fetch users: \(error)")
                    
                }
            })
        }
    }
    
    func filterUsers(with search: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetchedUsers else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        spinner.dismiss(animated: true)
        
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let username = $0["username"]?.lowercased() else {
                return false
            }
            
            return username.hasPrefix(search.lowercased())
        }).compactMap({
            guard let email = $0["email"], let username = $0["username"] else {
                return nil
            }
            return SearchResult(username: username, email: email)
        })
        
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            noUsersLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noUsersLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}



