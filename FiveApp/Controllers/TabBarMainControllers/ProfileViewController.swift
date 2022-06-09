//
//  ProfileViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import FirebaseAuth
import SDWebImage

class ProfileViewController: MainViewController {
     
    var tableView: UITableView!
    var profilePicImage: UIImageView!
    
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Username:  \(UserDefaults.standard.value(forKey: "username") as? String ?? "No Name")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email:           \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log out", handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                UserDefaults.standard.set(nil, forKey: "email")
                UserDefaults.standard.set(nil, forKey: "username")
                UserDefaults.standard.set(nil, forKey: "admin")
                
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
            strongSelf.present(actionSheet, animated: true)
        }))
        
        
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
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.id)
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/" + fileName
        
        let profilePicHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
        profilePicImage = UIImageView(frame: CGRect(x: (view.frame.size.width-150)/2, y: 25, width: 150, height: 150))
        
        profilePicImage.isUserInteractionEnabled = true
        tableView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        profilePicImage.addGestureRecognizer(gesture)
        
        profilePicImage.contentMode = .scaleAspectFill
        profilePicImage.layer.borderColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1).cgColor
        profilePicImage.layer.borderWidth = 3
        profilePicImage.layer.masksToBounds = true
        profilePicImage.layer.cornerRadius = profilePicImage.frame.width/2
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let URL):
                self?.downloadImage(imageView: (self?.profilePicImage)!, url: URL)
            case .failure(let error):
                print("Error getting the download URL: \(error)")
            }
        })
        
        profilePicHeader.addSubview(profilePicImage)
        profilePicHeader.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.2)
        return profilePicHeader
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        imageView.sd_setImage(with: url)
        
//        URLSession.shared.dataTask(with: url, completionHandler: { data, _ , error in
//            guard let data = data, error == nil else {
//                return
//            }
//            DispatchQueue.main.async {
//                imageView.image = UIImage(data: data)
//            }
//        }).resume()
    }


}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.id, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose a photo from library", style: .default, handler: { [weak self] _ in
            self?.presentLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentLibrary() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.profilePicImage.image = selectedImage
    
        guard let data = selectedImage!.pngData() else {
            return
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = "\(safeEmail)_profile_picture.png"
        StorageManager.shared.uploadProfilePic(with: data, fileName: fileName, completionHandler: { result in
            switch result {
            case .success(let downloadURL):
                UserDefaults.standard.set(downloadURL, forKey: "profile_picture")
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}


