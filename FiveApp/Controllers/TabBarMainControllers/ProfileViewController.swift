//
//  ProfileViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import FirebaseAuth

class ProfileViewController: MainViewController {
     
    var tableView: UITableView!
    
    let data = ["Log out"]
    
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
        tableView = UITableView()
        configureTableView()
        view.addSubview(tableView)
    }
    
    func styleViews() {
    }
    
    func defineLayoutForViews() {
        tableView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/" + fileName
        
        let profilePicHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
        let profilePicImage = UIImageView(frame: CGRect(x: (self.view.frame.size.width-150)/2, y: 25, width: 150, height: 150))
        
        profilePicImage.contentMode = .scaleAspectFill
        profilePicImage.layer.borderColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1).cgColor
        profilePicImage.layer.borderWidth = 3
        profilePicImage.layer.masksToBounds = true
        profilePicImage.layer.cornerRadius = profilePicImage.frame.width/2
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let URL):
                self?.downloadImage(imageView: profilePicImage, url: URL)
            case .failure(let error):
                print("Error getting the download URL: \(error)")
            }
        })
        
        profilePicHeader.addSubview(profilePicImage)
        
        return profilePicHeader
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _ , error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }).resume()
    }


}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LogInViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                print("Failed to log out.")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
}
