//
//  NewChatViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import JGProgressHUD

class NewChatViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .extraLight)
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        view.addSubview(tableView)
        
        noUsersLabel = UILabel()
        noUsersLabel.text = "No Users Found"
        noUsersLabel.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold)
        noUsersLabel.textAlignment = .center
        noUsersLabel.textColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1)
        view.addSubview(noUsersLabel)
    }
    
    func styleViews() {
        searchBar.placeholder = "Search for Users"
        
        tableView.isHidden = true
        
        noUsersLabel.isHidden = true
    }
    
    func defineLayoutForViews() {
        
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    

}

extension NewChatViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
